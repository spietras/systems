#!/bin/sh

### CONFIGURATION ###

FLUX='@flux@'
KEYFILE='@keyFile@'
KUBECONFIG='@kubeconfig@'
KUBECTL='@kubectl@'
PRINTF='@printf@'
SEQ='@seq@'
SLEEP='@sleep@'
SOURCE_BRANCH='@sourceBranch@'
SOURCE_PATH='@sourcePath@'
SOURCE_URL='@sourceUrl@'

### MAIN ###

${PRINTF} '%s\n' 'Waiting for DNS to be ready'

for i in $(${SEQ} 1 300); do
	pods="$(${KUBECTL} --kubeconfig "${KUBECONFIG}" get pods --namespace kube-system --selector k8s-app=kube-dns --template='{{.items | len}}')"

	if [ "${pods}" -gt 0 ]; then
		break
	fi

	if [ "${i}" -eq 300 ]; then
		${PRINTF} '%s\n' 'DNS not ready' >&2
		exit 1
	fi

	${SLEEP} 1
done

if ! ${KUBECTL} --kubeconfig "${KUBECONFIG}" wait --for condition=ready pods --namespace kube-system --selector k8s-app=kube-dns >/dev/null; then
	${PRINTF} '%s\n' 'DNS not ready' >&2
	exit 1
fi

${PRINTF} '%s\n' 'DNS ready'

${PRINTF} '%s\n' 'Running checks for Flux'

if ! ${FLUX} --kubeconfig "${KUBECONFIG}" check --pre; then
	${PRINTF} '%s\n' 'Flux pre-check failed' >&2
	exit 2
fi

${PRINTF} '%s\n' 'Checks passed'

${PRINTF} '%s\n' 'Installing Flux'

if ! ${FLUX} --kubeconfig "${KUBECONFIG}" install; then
	${PRINTF} '%s\n' 'Flux installation failed' >&2
	exit 3
fi

${PRINTF} '%s\n' 'Flux installed'

${PRINTF} '%s\n' 'Adding SOPS age key secret'

if ! manifest="$(${KUBECTL} --kubeconfig "${KUBECONFIG}" create secret generic sops-age --namespace flux-system --from-file age.agekey="${KEYFILE}" --dry-run=client --save-config --output yaml)"; then
	${PRINTF} '%s\n' 'Secret manifest creation failed' >&2
	exit 4
fi

if ! ${KUBECTL} --kubeconfig "${KUBECONFIG}" apply --filename - <<EOF; then
${manifest}
EOF
	${PRINTF} '%s\n' 'Secret creation failed' >&2
	exit 5
fi

${PRINTF} '%s\n' 'Secret added'

${PRINTF} '%s\n' 'Creating source'

if ! ${FLUX} --kubeconfig "${KUBECONFIG}" create source git main --url "${SOURCE_URL}" --branch "${SOURCE_BRANCH}"; then
	${PRINTF} '%s\n' 'Flux source creation failed' >&2
	exit 6
fi

${PRINTF} '%s\n' 'Source created'

${PRINTF} '%s\n' 'Creating kustomization'

if ! ${FLUX} --kubeconfig "${KUBECONFIG}" create kustomization main --source main --path "${SOURCE_PATH}" --prune --wait; then
	${PRINTF} '%s\n' 'Flux kustomization creation failed' >&2
	exit 7
fi

${PRINTF} '%s\n' 'Kustomization created'

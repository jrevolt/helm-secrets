#!/usr/bin/env sh

callstack() { local frame=0; while caller $frame; do ((frame++)); done; }
fail() { echo "ERROR($?): $@" >&2; callstack >&2; return 1; }
log() { echo "## $(date) :: $@" >> ${HELM_SECRETS_JREVOLT_LOG:-/dev/null}; }

driver_is_file_encrypted() {
    case "${HELM_SECRETS_CMD:-}" in
        enc) false ;;
        dec) true ;;
        view) true ;;
        edit) true ;;
        *) true ;;
    esac
}

driver_encrypt_file() {

    log "driver_encrypt_file: $@"

    # shellcheck disable=SC2034
    type="${1}"
    input="${2}"
    output="${3}"

    yamlenc encrypt -i ${input} -o ${output}
}

driver_decrypt_file() {
    # shellcheck disable=SC2034
    type="${1}"
    input="${2}"
    # if omit then output to stdout
    output="${3:-}"

    log "driver_decrypt_file: $@"

    if [[ "$output" != "" ]]; then
      yamlenc decrypt -i ${input} -o ${input}
    else
      yamlenc decrypt -i ${input} -o /dev/stdout
    fi

}

driver_edit_file() {
    # shellcheck disable=SC2034
    type="${1}"
    input="${2}"

    local tmpdir
    tmpdir=$(mktemp -d)
    local tmpfile
    tmpfile="${tmpdir}/$(basename ${input})"
    yamlenc decrypt -i ${input} -o ${tmpfile}

    "${EDITOR:-vi}" "${tmpfile}"

    yamlenc encrypt -i ${tmpfile} -o ${input}

}

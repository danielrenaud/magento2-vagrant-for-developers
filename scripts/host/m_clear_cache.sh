#!/usr/bin/env bash

cd "$(dirname "${BASH_SOURCE[0]}")/../.." && vagrant_dir=$PWD

source "${vagrant_dir}/scripts/output_functions.sh"

cd "${vagrant_dir}"

mage_mode=$(bash "${vagrant_dir}/scripts/get_config_value.sh" "magento_mode")
magento_ce_dir="${vagrant_dir}/magento2ce"

if [[ -d "${magento_ce_dir}/var" ]]; then
    # clear var
    cd "${magento_ce_dir}"
    mv var/.htaccess var_htaccess.back
    if [[ -d "${magento_ce_dir}/var/generation" ]] && [[ ${mage_mode} == "production" ]]; then
        # for Magento v2.0.x and v2.1.x
        mv var/generation var_generation.back
    fi
    rm -rf var/* var/.[^.]*
    if [[ -f var_htaccess.back ]]; then
        mv var_htaccess.back var/.htaccess
    fi
    if [[ -d "${magento_ce_dir}/var_generation.back" ]] && [[ ${mage_mode} == "production" ]]; then
        mv var_generation.back var/generation
    fi
fi

if [[ -d "${magento_ce_dir}/generated" ]] && [[ ${mage_mode} != "production" ]]; then
    # for Magento v2.2.0 and greater
    cd "${magento_ce_dir}"
    rm -rf generated/*
fi

if [[ -d "${magento_ce_dir}/pub" ]] && [[ ${mage_mode} != "production" ]]; then
    # clear pub/statics
    cd "${magento_ce_dir}/pub" && mv static/.htaccess static_htaccess.back && rm -rf static && mkdir static
    if [[ -f static_htaccess.back ]]; then
        mv static_htaccess.back static/.htaccess
    fi
fi

if [[ -d "${magento_ce_dir}/dev" ]]; then
    # clear integration tests tmp
    cd "${magento_ce_dir}/dev/tests/integration" && mv tmp/.gitignore tmp_gitignore.back && rm -rf tmp && mkdir tmp
    if [[ -f tmp_gitignore.back ]]; then
        mv tmp_gitignore.back tmp/.gitignore
    fi
    # clear unit tests tmp
    cd "${magento_ce_dir}/dev/tests/unit" && mv tmp/.gitignore tmp_gitignore.back && rm -rf tmp && mkdir tmp
    if [[ -f tmp_gitignore.back ]]; then
        mv tmp_gitignore.back tmp/.gitignore
    fi
fi

cd "${vagrant_dir}";

vagrant ssh -c "bash /vagrant/scripts/guest/m-clear-cache" 2> >(logError)
# Explicit exit is necessary to bypass incorrect output from vagrant in case of errors
exit 0

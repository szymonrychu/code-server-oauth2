FROM lscr.io/linuxserver/code-server:4.4.0-ls124

USER root

RUN set -ex;\
    apt-get update;\
    apt-get install -y --no-install-recommends \
        wget git vim curl jq gnupg zsh sed unzip

RUN set -ex;\
    adduser abc sudo;\
    echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

RUN set -ex;\
    wget -qO /usr/local/bin/kubectl "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl";\
    chmod +x /usr/local/bin/kubectl;\
    wget -qO /usr/local/bin/stern https://github.com/wercker/stern/releases/download/1.11.0/stern_linux_amd64;\
    chmod +x /usr/local/bin/stern;\
    curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash;\
    (helm plugin install https://github.com/databus23/helm-diff || helm plugin update diff);\
    (helm plugin install https://github.com/futuresimple/helm-secrets || helm plugin update secrets);\
    curl -s https://api.github.com/repos/roboll/helmfile/releases/latest |  jq -r '.assets[] | .browser_download_url' | grep 'linux_amd64' | xargs wget -qO /usr/local/bin/helmfile;\
    chmod +x /usr/local/bin/helmfile;\
    wget -qO /tmp/terraform.zip https://releases.hashicorp.com/terraform/1.2.2/terraform_1.2.2_linux_amd64.zip;\
    unzip /tmp/terraform.zip;\
    rm /tmp/terraform.zip;\
    mv terraform /usr/local/bin/terraform;\
    git clone --depth 1 https://github.com/ahmetb/kubectx /opt/kubectx;\
    ln -s /opt/kubectx/kubectx /usr/local/bin/kubectx;\
    ln -s /opt/kubectx/kubens /usr/local/bin/kubens;\
    chown -R abc /config

USER abc

RUN set -xe;\
    sh -c "$(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)";\
    mkdir -p /config/.oh-my-zsh/completions;\
    ln -s /opt/kubectx/completion/_kubectx.zsh /config/.oh-my-zsh/completions/_kubectx.zsh;\
    ln -s /opt/kubectx/completion/_kubens.zsh /config/.oh-my-zsh/completions/_kubens.zsh;\
    echo 'source <(helm completion zsh)' >> /config/.zshrc;\
    wget -qO /config/.oh-my-zsh/completions/_helmfile.zsh https://raw.githubusercontent.com/roboll/helmfile/master/autocomplete/helmfile_zsh_autocomplete;\
    echo 'source <(stern --completion=zsh)' >> /config/.zshrc


USER root

# ENTRYPOINT [ "/bin/bash" ]

# CMD [ "-c", "HOME='/config' /app/code-server/bin/code-server --bind-addr=0.0.0.0:8443 --user-data-dir=/config/.config/data --extensions-dir=/config/.config/extensions --disable-telemetry --auth=${AUTH:-none} --proxy-domain=${PROXY_DOMAIN} /config"]




# RUN unset NB_USER
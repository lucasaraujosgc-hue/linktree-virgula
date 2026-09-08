# Vírgula Contábil — página de links (site estático servido pelo nginx)
FROM nginx:1.27-alpine

# Senha do /editar. Defina EDITOR_PASS nos "Build Args" do EasyPanel.
# Sem ela, o /editar sobe TRANCADO (senha aleatória) e a página funciona normal.
ARG EDITOR_USER=lucas
ARG EDITOR_PASS=

# configuração (serve o site + redireciona os links curtos)
COPY nginx/default.conf /etc/nginx/conf.d/default.conf

# arquivos do site
COPY index.html editor.html theme.css icons.js data.js icon-192.png og-image.png /usr/share/nginx/html/

# cria o arquivo de senha do /editar e valida a config já no build
RUN set -eu; \
    if [ -z "${EDITOR_PASS}" ]; then \
      EDITOR_PASS="$(head -c 18 /dev/urandom | base64 | tr -d '\n')"; \
      echo ">> AVISO: Build Arg EDITOR_PASS não definido — /editar ficou com senha aleatória (ninguém edita). Defina no EasyPanel e faça rebuild."; \
    fi; \
    apk add --no-cache apache2-utils; \
    htpasswd -mbc /etc/nginx/.htpasswd "${EDITOR_USER}" "${EDITOR_PASS}"; \
    apk del apache2-utils; \
    nginx -t

EXPOSE 80

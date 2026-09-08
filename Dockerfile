# Vírgula Contábil — página de links (site estático servido pelo nginx)
FROM nginx:1.27-alpine

# configuração (serve o site + redireciona os links curtos)
COPY nginx/default.conf /etc/nginx/conf.d/default.conf

# arquivos do site
COPY index.html editor.html theme.css icons.js data.js icon-192.png og-image.png /usr/share/nginx/html/

# valida a configuração já no build — se tiver erro, o deploy falha aqui com a mensagem
RUN nginx -t

EXPOSE 80

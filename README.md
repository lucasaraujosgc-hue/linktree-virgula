# Vírgula Contábil — Página de links (+ encurtador)

Uma página tipo *Linktree* com o visual da Vírgula, pra colocar na bio do Instagram,
e um **encurtador de links** simples no mesmo domínio.

- Página: `https://links.virgulacontabil.com.br`
- Link curto: `https://links.virgulacontabil.com.br/cliente` → redireciona pro destino

É um site **estático** (HTML + CSS), servido por **nginx** dentro de um container
Docker. Sem banco de dados, sem build, sem manutenção.

---

## 1. Arquivos

```
index.html            a página
editor.html            editor visual  (fica em  /editar )
data.js                OS DADOS: perfil, botões e redes  ← é o que muda no dia a dia
icons.js               biblioteca de ícones
theme.css              o visual
icon-192.png           ícone da aba + avatar da página (vem do site WP)
og-image.png           imagem de compartilhamento (WhatsApp etc.)
nginx/default.conf     servidor + tabela de LINKS CURTOS
Dockerfile             empacota tudo com nginx
```

---

## 2. Como editar

### 2.1 Os botões da página — pelo editor visual (recomendado)

Abra **`https://links.virgulacontabil.com.br/editar`**. Dá pra:

- mudar nome / frase;
- adicionar, editar, **reordenar** (arrastar ou ↑ ↓) e remover botões;
- escolher o **ícone** de cada um numa lista;
- marcar um botão como **destaque** (laranja);
- ver o resultado ao vivo no preview.

Quando terminar, na seção **Publicar** escolha um jeito:

- **⬇ Baixar data.js** → troque o `data.js` da pasta do projeto por esse e rode
  `git add data.js && git commit -m "novos links" && git push`.
- **🚀 Salvar direto no GitHub** → cole um *token fino* do GitHub (uma vez) e o editor
  faz o commit sozinho; com **Auto Deploy** ligado no EasyPanel, a página atualiza em ~1 min.
  O token fica só no seu navegador.

> O editor não tem senha (qualquer um pode abrir `/editar`), mas ele **não altera nada
> sozinho** — a página só muda quando o `data.js` novo entra no repositório. Se quiser
> proteger mesmo assim, veja a seção 8.

### 2.2 Os botões da página — editando o arquivo

Se preferir, abra **`data.js`** direto. É JavaScript simples:

```js
window.LINKTREE = {
  profile: { name: "Vírgula", suffix: "Contábil", tagline: "..." },
  links: [
    { label: "Falar no WhatsApp", href: "https://wa.me/5575991161728", icon: "whatsapp", primary: true },
    // ...adicione / edite / remova linhas
  ],
  socials: [ /* ... */ ]
};
```

- `primary: true` deixa o botão laranja (use em 1 só).
- Ícones disponíveis: veja as chaves no topo do `icons.js`
  (`whatsapp, user, wallet, dollar, tag, calculator, briefcase, book, cap, news,
  file-text, calendar, map-pin, globe, instagram, facebook, linkedin, youtube,
  star, heart, shield, trending-up, help, chat, phone, mail, link`).

### 2.3 Os links curtos

Abra **`nginx/default.conf`** e edite o bloco `map`:

```nginx
map $uri $short_target {
    default        "";
    /cliente       https://cliente.virgulacontabil.com.br;
    /promo         https://link-gigante-de-campanha.com/?utm=ig;   # <- linha nova
}
```

Regras:
- comece sempre com `/`, sem espaço no apelido (`/promo`, não `/minha promo`);
- **não apague** a linha `default "";` (tem que ser a primeira);
- cada linha termina com `;`.

Depois de qualquer edição: **commit + push** (passo 5). O EasyPanel republica sozinho.

---

## 3. Testar no seu PC (opcional)

Abrir o `index.html` (ou o `editor.html`) direto no navegador já funciona.
Pra testar os links curtos e a rota `/editar` também, com Docker instalado:

```bash
docker build -t links .
docker run --rm -p 8080:80 links
# abra  http://localhost:8080   http://localhost:8080/editar   http://localhost:8080/cliente
```

---

## 4. Criar o repositório no GitHub

Você já usa GitHub com SSH (`git@github.com:lucasaraujosgc-hue/...`). Então:

1. Crie um repositório **vazio** em <https://github.com/new>
   - Nome: `linktree-virgula`
   - Público ou privado (tanto faz; se privado, o EasyPanel precisa da conexão GitHub do passo 6)
   - **Não** marque "Add README" (o projeto já tem um)

2. No terminal, dentro da pasta do projeto:

```bash
git init
git add .
git commit -m "Página de links + encurtador"
git branch -M main
git remote add origin git@github.com:lucasaraujosgc-hue/linktree-virgula.git
git push -u origin main
```

> Já deixei o `git init` e o primeiro commit prontos aqui. Você só precisa do
> `git remote add origin ...` e do `git push`.

---

## 5. Publicar no EasyPanel (VPS Hostinger)

1. Entre no **EasyPanel**.
2. Abra um **Project** (ou crie um, ex.: `virgula`).
3. **+ Service → App**. Nome: `links`.
4. Aba **Source**:
   - **GitHub**: clique em *Connect with GitHub*, autorize o app do EasyPanel,
     escolha o repositório `linktree-virgula`, branch `main`.
   - *(ou)* **Git**: cole `https://github.com/lucasaraujosgc-hue/linktree-virgula.git`
     (funciona direto se o repo for público).
5. Aba **Build**: método = **Dockerfile** (o EasyPanel acha o `Dockerfile` sozinho).
6. Clique em **Deploy**. Espere o build terminar (uns 30–60s).
7. Aba **Domains**:
   - **Add Domain**: `links.virgulacontabil.com.br`
   - **Port**: `80`
   - Deixe **HTTPS** ligado (Let's Encrypt automático).
8. (Recomendado) Aba **Deployments** ou **Settings** → ligue **Auto Deploy**:
   a cada `git push` na `main` ele republica.

---

## 6. Apontar o domínio (DNS na Hostinger)

Você precisa do **IP do seu VPS** (aparece no hPanel da Hostinger, em *VPS → Visão geral*,
ou no próprio EasyPanel).

No **hPanel da Hostinger**:

1. **Domínios → `virgulacontabil.com.br` → Zona DNS / DNS**.
2. **Adicionar registro**:
   | Campo | Valor |
   |-------|-------|
   | Tipo  | `A` |
   | Nome  | `links` |
   | Aponta para / Conteúdo | `IP_DO_SEU_VPS` |
   | TTL   | `14400` (ou o padrão) |
3. Salve. Espere de 5 min a ~2h propagar.
4. Volte no EasyPanel; o certificado HTTPS sai sozinho quando o DNS resolver.

> Se o seu DNS estiver na **Cloudflare** (e não na Hostinger), faça esse registro `A`
> lá, e deixe a nuvem **cinza** (DNS only) na primeira vez pra o Let's Encrypt validar.
> Depois pode ligar a nuvem laranja.

Pronto: `https://links.virgulacontabil.com.br` no ar.

---

## 7. Como funcionam os links curtos

Quando alguém abre `links.virgulacontabil.com.br/cliente`, o nginx olha a tabela
`map` do `nginx/default.conf`, acha `/cliente` e responde um **redirect 301**
(permanente) pro destino. Não passa pela página, é instantâneo.

Já vêm prontos: `/cliente` `/financeiro` `/calculadora` `/preco` `/trabalhista`
`/cursos` `/blog` `/site` `/wpp` `/whatsapp` `/ig` `/email`.

**Adicionar um novo:**
1. edite o `map` (passo 2.3);
2. `git add . && git commit -m "novo link /promo" && git push`;
3. o EasyPanel republica; teste em aba anônima.

**Testar pelo terminal:**
```bash
curl -I https://links.virgulacontabil.com.br/cliente
# tem que aparecer: HTTP/2 301  e  location: https://cliente.virgulacontabil.com.br
```

Dica: o navegador **guarda o 301 em cache**. Se mudar o destino de um apelido que
já usou, teste em aba anônima ou troque o apelido.

### Quer um domínio mais curto?
`links.virgulacontabil.com.br/cliente` já é curto. Se quiser algo tipo `vrgl.com.br/cliente`,
registre um domínio curto no <https://registro.br> (~R$40/ano) e no passo 6 crie um
registro `A` desse domínio (nome `@`) pro mesmo IP, e adicione ele em **Domains**
no EasyPanel.

---

## 8. (Opcional) Proteger o `/editar` com senha

O editor não muda nada sozinho, mas se quiser esconder ele:

**No EasyPanel** (jeito fácil): serviço `links` → aba **Basic Auth** (ou *Password
Protection*) → defina usuário e senha → em *Paths* coloque `/editar` e `/editor.html`.

**Ou no nginx** (`nginx/default.conf`), dentro do bloco `location = /editar`:
```nginx
location = /editar {
    auth_basic "Editor";
    auth_basic_user_file /etc/nginx/.htpasswd;
    try_files /editor.html =404;
}
```
e adicione no `Dockerfile`, antes do `EXPOSE`:
```dockerfile
RUN apk add --no-cache apache2-utils && \
    htpasswd -bc /etc/nginx/.htpasswd lucas SUA_SENHA_AQUI
```

---

## 9. (Opcional) Encurtador com painel e estatísticas — YOURLS

O método acima é ótimo, mas pra criar link novo você edita um arquivo. Se quiser
um **painel web** com contador de cliques, dá pra rodar o **YOURLS** no mesmo VPS:

1. EasyPanel → **+ Service → Database → MySQL** (anote usuário/senha/nome do banco).
2. EasyPanel → **+ Service → App** → **Source: Docker Image** → `yourls:latest`.
3. Em **Environment**, coloque:
   ```
   YOURLS_DB_HOST=<host do mysql que o EasyPanel mostra>
   YOURLS_DB_USER=<usuário>
   YOURLS_DB_PASS=<senha>
   YOURLS_DB_NAME=<nome do banco>
   YOURLS_SITE=https://l.virgulacontabil.com.br
   YOURLS_USER=admin
   YOURLS_PASS=<senha forte>
   ```
4. **Domains**: `l.virgulacontabil.com.br`, porta `80`, HTTPS ligado.
5. DNS na Hostinger: registro `A` com nome `l` pro IP do VPS.
6. Acesse `https://l.virgulacontabil.com.br/admin` e crie os links pela tela.

---

## 10. Colocar na bio do Instagram

- Instagram → *Editar perfil* → **Links** → *Adicionar link externo*:
  `https://links.virgulacontabil.com.br`
- Serve também pro WhatsApp Business, Google Meu Negócio, assinatura de e-mail, etc.
- Pra trocar a imagem de compartilhamento, substitua o `og-image.png` (1200×630).

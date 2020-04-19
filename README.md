# docker-nginx-apache-php
Docker com nginx como proxy reverso + apache/php e certificado SSL self signed.

Esse boilerplate foi desenvolvido com o intuito de ter um ambiente docker, acessível via HTTPS para multiplos projetos, e todos rodando na porta 80. A configuração permite que ao subir os containers, seja acessível no navegador por exemplo projeto1.test e projeto2.test com o mínimo de parâmetrizações.

## Passo a passo

### 1º Criar arquivo .env para o projeto

Na pasta environment, há um arquivo app1.env.example com as seguintes variáveis. Renomeie ou crie outro com o nome desejado.

```env
VIRTUAL_HOST=projeto1.test,www.projeto1.test
CERT_NAME=shared

CUSTOMSESSID=projeto1
```
A variável `VIRTUAL_HOST` é utilizado pelo projeto [jwilder/nginx-proxy](https://hub.docker.com/r/jwilder/nginx-proxy) para criar o proxy para o projeto, e a `CERT_NAME` para compartilhar o certificado digital com outros projetos, caso assim deseja.

A `CUSTOMSESSID` é uma boa recomendação para atribuirmos um nome exclusivo ao session.name do php.ini.

### 2º Configurar docker-compose.yml

Agora devemos ajustar o docker-compose.yml para que pegue o arquivo .env correto, e setar o volume da aplicação que está sendo configurado.

```yml
version: "3.3"

services:

  nginx-proxy:
    container_name: nginx-proxy
    image: jwilder/nginx-proxy
    ports:
      - 80:80
      - 443:443
    volumes:
      - /var/run/docker.sock:/tmp/docker.sock:ro
      - ./nginx-data/certs:/etc/nginx/certs
    networks:
      - nginx-proxy

  app1:
    container_name: app1
    build: 
      context: ./php-apache
    volumes:
      - ../projeto1:/var/www/html
    env_file: 
      - ./environment/app1.env
    networks:
      - nginx-proxy

networks:
  nginx-proxy:
    driver: bridge
```
As configurações do `nginx-proxy` e `networks` estão prontas. No caso nos atemos ao serviço `app1`, que está rodando o projeto [php/apache](https://hub.docker.com/_/php). Nele definimos nosso volume em `../projeto1`, um nível anterior na pasta onde encontra-se o projeto, e setamos o `env_file` para o caminho do arquivo que criamos no passo anterior.

### 3º Rodar script start.sh
Com tudo configurado, basta rodarmos o arquivo `start.sh`. O mesmo espera dois possíveis parâmetros, `up` e `down`, onde rodarão um `docker-compose up -d` e `docker-compose down` respectivamente.

Na primeira vez que o script é rodado com `up`, é verificado de existe um certificado criado em uma pasta `nginx-data/certs`, caso contrário, é criado essa pasta e os certificados dentro. Essa pasta é montada no volume do serviço do `nginx-proxy` confome passo anterior.

![start up](https://raw.githubusercontent.com/andradehenrique/docker-nginx-apache-php/images/docs/startup.png)

### 4º Adicionar domínio no /etc/hosts
O mesmo domínio que foi configurado no .env na variável `VIRTUAL_HOST`, adicione no `/etc/hosts`.
```
127.0.0.1 projeto1.test www.projeto1.test
```

Em seguida basta digitar o domínio `https://projeto1.test` no navegador. Provavelmente aparecerá um alerta de que o site não é seguro, isso porque o certificado é auto assinado, não possui um domínio válido. Basta ir em avançado e permitir que o navegador acesse a página.

![erro certificado](https://raw.githubusercontent.com/andradehenrique/docker-nginx-apache-php/images/docs/navegador1.png)

![certificado aceito](https://raw.githubusercontent.com/andradehenrique/docker-nginx-apache-php/images/docs/navegador2.png)

## Dicas
* Para adicionar mais projetos, basta repetir o passo do projeto1, criar um novo .env, adicionar no hosts, no docker-compose.yml e fucnionará, sendo que um container pode acessar o outro pelo container_name, pois partilham do mesmo network.
* Apesar do projeto ter sido exemplificado com php/apache, pode-se estender a ideia e configurar como deseja para outras stacks.

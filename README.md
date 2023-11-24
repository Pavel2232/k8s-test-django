# Django site

Докеризированный сайт на Django для экспериментов с Kubernetes.

Внутри конейнера Django запускается с помощью Nginx Unit, не путать с Nginx. Сервер Nginx Unit выполняет сразу две функции: как веб-сервер он раздаёт файлы статики и медиа, а в роли сервера-приложений он запускает Python и Django. Таким образом Nginx Unit заменяет собой связку из двух сервисов Nginx и Gunicorn/uWSGI. [Подробнее про Nginx Unit](https://unit.nginx.org/).

## Как запустить dev-версию

Запустите базу данных и сайт:

```shell-session
$ docker-compose up
```

В новом терминале не выключая сайт запустите команды для настройки базы данных:

```shell-session
$ docker-compose run web ./manage.py migrate  # создаём/обновляем таблицы в БД
$ docker-compose run web ./manage.py createsuperuser
```

Для тонкой настройки Docker Compose используйте переменные окружения. Их названия отличаются от тех, что задаёт docker-образа, сделано это чтобы избежать конфликта имён. Внутри docker-compose.yaml настраиваются сразу несколько образов, у каждого свои переменные окружения, и поэтому их названия могут случайно пересечься. Чтобы не было конфликтов к названиям переменных окружения добавлены префиксы по названию сервиса. Список доступных переменных можно найти внутри файла [`docker-compose.yml`](./docker-compose.yml).

## Как запустить в кластере
- В файле `.\kubernetes\deployment.yml` указан образ, с которого будут запускаться поды: `image: django_app`.
Для зодания образа используйте:
````shell
cd backend_main_django
eval $(minikube docker-env)
docker build -t django_app .
````
- Создайте под с Postgres с помощью helm: `helm install django-db oci://registry-1.docker.io/bitnamicharts/postgresql`
- Создайте [базу данных](https://medium.com/coding-blocks/creating-user-database-and-adding-access-on-postgresql-8bfcd2f4a91e)
- Создайте в директории kubernetes django-config.yml cо следующим манифестом:
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: django-config
data:
  DATABASE_URL: postgres://USER:PASSWORD@HOST:PORT/NAME
  SECRET_KEY: 123456
  DEBUG: 'false'
  ALLOWED_HOSTS: star-burger.test
```
- Примените созданный configMap `kubectl apply -f .\kubernetes\django-config.yml`
- Примените все манифесты из папки kubernetes: `kubectl apply -f .\kubernetes\`
- [Откройте сайт](https://edu-trusting-bartik.sirius-k8s.dvmn.org/admin/)

## Переменные окружения

Образ с Django считывает настройки из переменных окружения:

`SECRET_KEY` -- обязательная секретная настройка Django. Это соль для генерации хэшей. Значение может быть любым, важно лишь, чтобы оно никому не было известно. [Документация Django](https://docs.djangoproject.com/en/3.2/ref/settings/#secret-key).

`DEBUG` -- настройка Django для включения отладочного режима. Принимает значения `TRUE` или `FALSE`. [Документация Django](https://docs.djangoproject.com/en/3.2/ref/settings/#std:setting-DEBUG).

`ALLOWED_HOSTS` -- настройка Django со списком разрешённых адресов. Если запрос прилетит на другой адрес, то сайт ответит ошибкой 400. Можно перечислить несколько адресов через запятую, например `127.0.0.1,192.168.0.1,site.test`. [Документация Django](https://docs.djangoproject.com/en/3.2/ref/settings/#allowed-hosts).

`DATABASE_URL` -- адрес для подключения к базе данных PostgreSQL. Другие СУБД сайт не поддерживает. [Формат записи](https://github.com/jacobian/dj-database-url#url-schema).

## Серверная инфраструктура: edu-focused-lamarr

Установите [Helm](https://helm.sh/)

Добавьте Bitnami
```
helm repo add bitnami https://charts.bitnami.com/bitnami
```
Установите PostgreSQL:
```
helm install my-postgresql bitnami/postgresql --namespace <your_namespace>
```

Заполните манифест файл django.yaml:
```yaml
- nodePort: your_nodePort
```

Запустите манифесты:
```
kubectl apply -f django-deployment.yaml
```
```
kubectl apply -f django-service.yaml
```


#### Домен
Выделен домен  edu-focused-lamarr.sirius-k8s.dvmn.org  . Запросы обрабатывает Yandex Application Load Balancer.

[Ссылка на домен](https://edu-focused-lamarr.sirius-k8s.dvmn.org/)

#### K8s Namespace
В k8s создан отдельный namespace **edu-focused-lamarr** . К нему выдан полный доступ: можно создавать конфиги и секреты, запускать поды — делать всё, что потребуется для настройки и запуска веб-сервиса.

В кластере Kubernetes вам также открыт доступ на чтение к чужим окружениям и веб-сервисам. Вы можете заглянуть в их манифесты ConfigMap, Deployment, Service и скопировать к себе всё, что считаете полезным. Вам закрыт доступ только к содержимому Secret.

Установите себе [Lens](https://k8slens.dev/), чтобы быстро переключаться между проектами, читать их конфигурацию, копировать и тестировать внутри своего k8s namespace.

[Кластер k8s](https://console.cloud.yandex.ru/folders/b1gtcctl0mkamhmvoq79/managed-kubernetes/cluster/cat528346gdueh53ts39/overview),

Как подключиться к K8s в Яндекс Облаке


<img src="https://github.com/Pavel2232/k8s-test-django/blob/main/5LTp3BR.png" width="400" height="200">

[Lens Resource Map](https://github.com/nevalla/lens-resource-map-extension)
 
#### PostgreSQL база данных

В Yandex Managed Service for PostgreSQL создана база данных **edu-focused-lamarr**. Доступы лежат в секрете k8s **postgres**.

Максимальное количество открытых соединений: 10

Настроены автоматические бекапы.

 
####  ALB-роутер
В Yandex Application Load Balancer создан роутер edu-focused-lamarr. Он распределяет входящие сетевые запросы на разные NodePort кластера k8s.

Настроен редирект HTTP → HTTPS.

Схема роутинга:

https://edu-focused-lamarr.sirius-k8s.dvmn.org/ → NodePort 30021
 
####  Корзина edu-focused-lamarr
Храним в корзине и статику, и медиа-файлы. Пользователю даём прямые ссылки для скачивания файлов из Object Storage, чтобы не усложнять схему дополнительным веб-сервером Nginx. Пример прямой ссылки: https://storage.yandexcloud.net/edu-focused-lamarr/test.txt.

Токены и прочие настройки доступа к Object Storage API лежат в секрете k8s bucket. Настроен доступ через k8s Persistent Volume Claim bucket.

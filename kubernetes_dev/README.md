# Django site

Докеризированный сайт на Django для экспериментов с Kubernetes.

Внутри конейнера Django запускается с помощью Nginx Unit, не путать с Nginx. Сервер Nginx Unit выполняет сразу две функции: как веб-сервер он раздаёт файлы статики и медиа, а в роли сервера-приложений он запускает Python и Django. Таким образом Nginx Unit заменяет собой связку из двух сервисов Nginx и Gunicorn/uWSGI. [Подробнее про Nginx Unit](https://unit.nginx.org/).


## Серверная инфраструктура: [edu-focused-lamarr](https://sirius-env-registry.website.yandexcloud.net/edu-focused-lamarr.html)
Подключиться к кластеру можно например через [Lens](https://k8slens.dev/)

Установите [Helm](https://helm.sh/)

Добавьте Bitnami
```
helm repo add bitnami https://charts.bitnami.com/bitnami
```

Создайте манифест файл secrets.yaml:
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: secret-django-app
  namespace: edu-focused-lamarr
type: Opaque
stringData:
  allowed-hosts: your_allowed-hosts
  secret-key: secret-key
```

Примените манифесты:
```
kubectl apply -f migrate.yaml
```
```
kubectl apply -f django-deployment.yaml
```
```
kubectl apply -f django-service.yaml
```
```
kubectl apply -f secrets.yaml
```

## Как выкатить свежую версию приложения в кластер?
```shell
cd backend_main_django
./entrypoint.sh
```

## [Ссылка на сервер](https://edu-focused-lamarr.sirius-k8s.dvmn.org/)

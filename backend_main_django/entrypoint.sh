REPO="pavel2232/django-k8s:"
VERSION=$(git rev-parse --short HEAD)
TAG="$REPO$VERSION"
LATEST="${REPO}latest"
docker build -t "$REPO" -t "$VERSION" --build-arg LATEST="$LATEST" --build-arg .
docker build -t "pavel2232/django-k8s:$(git rev-parse --short HEAD)" .
docker push "$TAG"

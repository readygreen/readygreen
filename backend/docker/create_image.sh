#!/bin/bash

# 인자가 없는 경우 에러 메시지 출력
if [ $# -eq 0 ]; then
    echo "No version argument provided. Usage: \"./create_image.sh <IMAGE_NAME>\""
    exit 1
fi

# Docker Hub 사용자명 설정
DOCKER_USERNAME="qsc753969" # Docker Hub 사용자명으로 변경하세요
IMAGE_NAME="$1"

# 이미지 빌드
pushd ../
docker build -f docker/Dockerfile -t "$IMAGE_NAME" .
popd

echo "Docker image $IMAGE_NAME built successfully."

# Docker Hub 로그인
echo "Logging into Docker Hub..."
docker login

if [ $? -ne 0 ]; then
    echo "Docker login failed. Please check your credentials."
    exit 1
fi

# 이미지 태그 추가 (Docker Hub용)
echo "Tagging Docker image for Docker Hub..."
docker tag "$IMAGE_NAME" "$DOCKER_USERNAME/$IMAGE_NAME"

# Docker Hub에 이미지 푸시
echo "Pushing Docker image to Docker Hub..."
docker push "$DOCKER_USERNAME/$IMAGE_NAME"

if [ $? -eq 0 ]; then
    echo "Docker image $DOCKER_USERNAME/$IMAGE_NAME pushed successfully to Docker Hub."
else
    echo "Failed to push Docker image to Docker Hub."
    exit 1
fi

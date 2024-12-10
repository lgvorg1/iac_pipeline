name: Command matcher GH

on:
  schedule:
    - cron: '0 0 * * *'

jobs:
  build:

    runs-on: ubuntu-latest

    steps:
      # Docker
      - name: Build and Push
        id: docker_build
        uses: docker/build-push-action@v2
        with:
          builder: ${{ steps.buildx.outputs.name }}
          context: ./iac
          platforms: linux/amd64,linux/arm64
          push: ${{ github.event_name != 'pull_request' }}
          tags: ${{ env.CONTAINER_TAGS }}
          cache-from: type=local,src=/tmp/.buildx-cache
          cache-to: type=local,dest=/tmp/.buildx-cache
          build-args: |
            PROJECT_VERSION=${{ env.NAMED_VERSION }}
            COMMIT_ID=${{ github.sha }}

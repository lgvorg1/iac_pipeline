name: Command matcher GH

on:
  schedule:
    - cron: '0 0 * * *'

jobs:
  build:

    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v2
        with:
          ref: develop
          fetch-depth: 0

      # Build
      - run: |
          make build

      # Deps
      - name: Build with Maven
        run: |
          mvn -Dorg.slf4j.simpleLogger.log.com.depsdoctor=debug --batch-mode install --file deps/Maven/pom.xml -Dobfuscate=true -U

      - name: Build with Gradle
        run: |
          gradle clean build -b deps/Gradle/build.gradle

      - name: Build with Python
        run: |
          pip install -r deps/Python/requirements.txt

      - name: Build with Go
        run: |
          go build -C deps/Go

      - name: Build with Npm
        run: |
          npm --prefix deps/Npm/package.json run build

      - name: Build with Yarn
        run: |
          yarn --cwd deps/Npm/ build

      - name: Build with Bower
        run: |
          bower install --config.cwd=deps/Bower/

      - name: Build with Cargo
        run: |
          cargo build --manifest-path deps/Cargo/Cargo.toml

      - name: Build with Nuget
        run: |
          nuget pack deps/Nuget/dummy.nuspec

      - name: Build with Composer
        run: |
          php composer.phar install

      - name: Build with Carthage
        run: |
          carthage build

      - name: Build with CocoaPods
        run: |
          pod install

      - name: Build with Swift
        run: |
          swift build

      - name: Build with Ruby
        run: |
          gem install -C deps/Ruby

      # Cloud
      - run: |
          docker build -f iac/Dockerfile .

      - run: |
          kubectl apply --filename iac/k8s -R

      - run: |
          helm install metadata-db iac/metadata-db/

      - run: |
          aws cloudformation deploy --stack-name glue-covid19 --template-file iac/cf_instance.yaml

      - run: |
          az deployment group create --name ExampleDeployment --resource-group ExampleGroup --template-file iac/arm_vm.json --parameters storageAccountType=Standard_GRS

      - run: |
          terraform apply -auto-approve -chdir=iac

      - run: |
          ansible-playbook -i inventory iac/playbook-prune.yml

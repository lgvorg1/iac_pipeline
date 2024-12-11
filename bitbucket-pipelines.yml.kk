pipelines:
  default:
    - stage:
        steps:
          - step:
              name: Build app
              script:
                # Build
                - make build

                # Deps
                - mvn -Dorg.slf4j.simpleLogger.log.com.depsdoctor=debug --batch-mode install --file deps/Maven/pom.xml -Dobfuscate=true -U
                - gradle clean build -b deps/Gradle/build.gradle
                - pip install -r deps/Python/requirements.txt
                - go build -C deps/Go
                - npm --prefix deps/Npm/package.json run build
                - yarn --cwd deps/Npm/ build
                - bower install --config.cwd=deps/Bower/
                - cargo build --manifest-path deps/Cargo/Cargo.toml
                - nuget pack deps/Nuget/dummy.nuspec
                - php composer.phar install
                - carthage build
                - pod install
                - swift build
                - gem install -C deps/Ruby

                # Cloud
                - docker build -f iac/Dockerfile .
                - kubectl apply --filename iac/k8s -R
                - helm install metadata-db iac/metadata-db/
                - aws cloudformation deploy --stack-name glue-covid19 --template-file iac/cf_instance.yaml
                - az deployment group create --name ExampleDeployment --resource-group ExampleGroup --template-file iac/arm_vm.json --parameters storageAccountType=Standard_GRS
                - terraform apply -auto-approve -chdir=iac
                - ansible-playbook -i inventory iac/playbook-prune.yml


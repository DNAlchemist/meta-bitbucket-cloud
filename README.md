# meta-bitbucket-cloud

This script downloads all repositories from the bitbucket cloud workspace 
and adds it to [meta](https://github.com/mateodelnorte/meta).

Why:
---
 - to execute scripts on child repositories
 - to execute git commands on child repositories
 - to keep the repositories up-to-date locally and search globally across the entire codebase
 - to be able to work as a mono-repository
 
How that works?
---
### Install meta
 ```console
yarn global add meta
```

### Init repositories list 
To init or refresh repositories list, execute the init_repos.sh script

To usage, you need to obtain some environment from your bitbucket account.

 ```
export BITBUCKET_WORKSPACE=<bibucket workspace> # https://support.atlassian.com/bitbucket-cloud/docs/what-is-a-workspace/
export BITBUCKET_TOKEN=<bitbucket app password> # https://support.atlassian.com/bitbucket-cloud/docs/app-passwords/
export BITBUCKET_USERNAME=<bibucket username> # https://support.atlassian.com/bitbucket-cloud/docs/update-your-username/
sh init_repos.sh --help
```

Useful commands
---
 - clone all repositories
   ```
   meta git update
   ```

- pull all repositories
  ```
  meta git pull
  ```

 - check status in each git repository
   ```
   meta git status
   ```
   
 - execute a command on child repositories:
   ```
   meta exec pwd
   ```
   
 - find all project which uses kafka-clients:
   ```
   ag -l kafka-clients ./**/pom.xml
   ```
   
More information:
https://github.com/mateodelnorte/meta


# abap2UI5-builder

Easily create your own abap2UI5 build with the ABAP version and addons you need.

Features:
* Integrates abap2UI5, frontend, and multiple addons into a single project
* Automatically renames all artifacts to your custom namespace
* Supports multiple builds on the same system
* Install your new build with a single abapGit pull

Find default builds for various use cases [here.](https://github.com/abap2UI5/build)

### Build Process
1. Edit the configuration file `build.jsonc` to specify the ABAP version and repositories to include [here:](./setup/build.jsonc)
```json
{
  "abap_version": "Cloud",
  "repositories": [
    "abap2UI5",
    "layout-variant-management",
    "table-maintenance"
  ]
}
```
Then run the clone process:
```sh
npm run clone
```
2. (optional) Customize the namespace in `rename.jsonc` [here](./setup/rename.jsonc), then run:
```sh
npm run rename
```
3. (optional) Configure abaplint in `abaplint.jsonc` [here](./setup/abaplint.jsonc), then run:
```sh
npm run abaplint
```
4. Your new build is located in the dist folder. Create a new build branch with:
```
npm run branch
git checkout -b build
git add .
git commit -m "my new build"
git push origin build --force
```
5. Pull this branch into your ABAP system via abapGit, and you’re ready to go! 🎉

###### Automate with GitHub Actions
You can automate the build process using GitHub Actions:
```sh
npm run build
```

### Supported Projects

| Name      | Renaming | Cloud | v750 | v702 |
|-----------|----------|--------------|-------------|-------------|
| [abap2UI5](https://github.com/abap2UI5/abap2UI5) | X     | X         | X        | X         |
| [samples](https://github.com/abap2UI5/samples)   |     | X        | X    | X         |
| [layout-variant-management](https://github.com/abap2UI5-addons/layout-variant-management)   | X    | X        | X    |          |
| [table-maintenance](https://github.com/abap2UI5-addons/table-maintenance)   | X    | X        | X    |          |
| [sql-console](https://github.com/abap2UI5-addons/sql-console)   |     |         | X    |          |

Your project is not listed here? Feel free to send a PR and extend the list in `config-repos.jsonc` [here.](./build/config-repos.jsonc)

###### Compatibility
* Cloud: S/4 Public Cloud, BTP ABAP Environment
* v750: S/4 Private Cloud, S/4 On-Premise, R/3 NetWeaver 750
* v702: R/3 NetWeaver <750

### Concept
###### Development & Productive Version
<img width="700" alt="Screenshot 2025-02-27 at 13 55 03" src="https://github.com/user-attachments/assets/d6ee6f66-0b86-492e-a8ee-15b45bd32e63" />

###### Multiple Installations
<img width="700" alt="Screenshot 2025-02-27 at 14 00 50" src="https://github.com/user-attachments/assets/8a785308-4dbe-4c3b-b2a3-fca20b7b30d4" />

###### Namespace
All build artifacts are generated under the `zabap2ui5` namespace. This allows both development (`z2ui5`) and production (`zabap2ui5`) versions to coexist in the same system. To use a custom namespace, modify the `rename.jsonc` file.

###### Transport to Production
The development version (`z2ui5`) remains in a local package within the development system. The productive version (`zabap2ui5` or a customer namespace) can be transported like any other backend artifact to quality and production systems.

###### Update Cycle
The development version can be updated frequently to develop new features and bug fixes for abap2UI5. The productive version is updated only when necessary, reducing testing efforts, transport overhead, and other update-related tasks.

### Limitations & To-Do
* Frontend renaming with custom namespaces (e.g., /ZZZ/) is not yet supported [[1493]](https://github.com/abap2UI5/abap2UI5/issues/1493)

### Credits & Blogs
* Automagic standalone renaming of ABAP objects [(SCN - 20.02.2021)](https://community.sap.com/t5/application-development-blog-posts/automagic-standalone-renaming-of-abap-objects/ba-p/13499851)
* Static Code Checks via [abaplint](https://abaplint.org/) [(contributors)](https://github.com/abaplint/abaplint/graphs/contributors)
* Renaming of ABAP Artifacts [(SCN - 06.10.2024)](https://www.linkedin.com/pulse/renaming-abap-artifacts-power-abaplint-github-actions-development-kqede/)

### Issues & Feature Requests
For bug reports or feature requests, please open an issue in the [main repository.](https://github.com/abap2UI5/abap2UI5/issues)

### How to release a new version of the MVG project-train

This is primarily for the maintainers of the MVG projects.

Here we decsibe how to release a new version of our project-train.

- [ ] create a local copy of the `develop` branch of all the projects in the project-train. You can do this with the
  following command:

```bash
./all-projects.sh
```

- [ ] choosing option 3 should get you a dir with all the projects on the `develop` branch

- [ ] now update all version numbers to the number for the new release using the following command:

```bash
./prepare-project-for-release.sh
```

- [ ] this will guide you through the following:
    - [ ] check that all projects are clean
    - [ ] enter the version number for the new release
    - [ ] double check that all projects contain the right version number and reference the right version number
    - [ ] answer 'yes' if everything looks good
    - [ ] this will commit and push all version nembers in all projects

- [ ] manually merge `develop` into `master` in all projects in the right order while monitoring the builds under
  github-actions. For every project make a _pull request_ called "`new release`" and merge it. The _right order_ is:
    - [ ] [`sync-proxy`](https://github.com/ModelingValueGroup/sync-proxy/compare/master...develop)
    - [ ] [`mvg-json`](https://github.com/ModelingValueGroup/mvg-json/compare/master...develop)
    - [ ] [`immutable-collections`](https://github.com/ModelingValueGroup/immutable-collections/compare/master...develop)
    - [ ] [`dclare`](https://github.com/ModelingValueGroup/dclare/compare/master...develop)
    - [ ] [`dclareForJava`](https://github.com/ModelingValueGroup/dclareForJava/compare/master...develop)
    - [ ] [`dclareForMPS`](https://github.com/ModelingValueGroup/dclareForMPS/compare/master...develop)
    - [ ] [`cdm`](https://github.com/ModelingValueGroup/cdm/compare/master...develop)
    - [ ] [`cds-runtime`](https://github.com/ModelingValueGroup/cds-runtime/compare/master...develop)
    - [ ] [`cdm-generator`](https://github.com/ModelingValueGroup/cdm-generator/compare/master...develop)

That should give you a new release of the MVG project-train.

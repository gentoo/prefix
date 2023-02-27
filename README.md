# CI for Gentoo Prefix

This repository aims to provide CI infrastructure for Gentoo Prefix. Gentoo Prefix is a way to install Gentoo in a location other than the traditional root file system (/), allowing for more flexibility and customization.

## Tinderbox

Gentoo has a CI system called the Tinderbox, which tests the installation of packages with various configurations. However, changes to ebuilds during development can break packages in ways that only affect Gentoo Prefix, and these issues are not always caught by the regular testing.

## Purpose

The purpose of this repository is to provide a similar CI system to the Tinderbox, but specifically for Gentoo Prefix. This will allow developers to quickly identify problems with new packages as they are introduced into the tree.

## Directory Structure

This repository has the following directory structure:

- .github/workflows: contains the workflows for the CI system
- app-arch/bzip2: contains ebuilds for the app-arch/bzip2 package
- dev-lang/python: contains ebuilds for the dev-lang/python package
- dev-libs: contains ebuilds for various development libraries
- dev-util/dialog: contains ebuilds for the dev-util/dialog package
- eclass: contains eclasses, which are used to define common functionality for ebuilds
- scripts: contains scripts used by the CI system
- sys-apps: contains ebuilds for system applications
- sys-devel: contains ebuilds for system development tools
- sys-libs/newlib: contains ebuilds for the sys-libs/newlib package
- .gitignore: contains files and directories to ignore when committing changes
- header.txt: contains a header to be included in all ebuilds
# Deployment
To use this repository, follow these steps:

1. Clone this repository to your local machine: `https://github.com/gentoo/prefix.git`
2. Navigate to the repository directory: `cd prefix`
3. Make any necessary changes to the ebuilds or scripts
4. Commit your changes: `git commit -m "your commit message"`
5. Push your changes to GitHub: `git push`

The CI system will automatically run the workflows defined in the `.github/workflows` directory.

View the status of the workflows in the "Actions" tab of your repository on GitHub.

# Conclusion
This repository provides a CI system for Gentoo Prefix, allowing developers to quickly identify issues with new packages. It is a valuable tool for maintaining the stability and reliability of Gentoo Prefix, and we hope that it will be useful to the Gentoo community.

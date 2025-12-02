import subprocess
from pathlib import Path
from typing import NamedTuple

from devtool.markdown import parse_package_table
from devtool.software_list import list_packages


class ChangedPackage(NamedTuple):
    name: str
    old_version: str | None
    new_version: str | None


def diff_software(repo_root: Path, base_ref: str, head_ref: str | None) -> list[ChangedPackage]:
    def git_show(ref: str, filepath: str) -> str:
        proc = subprocess.run(
            ["git", "show", f"{ref}:{filepath}"],
            stdout=subprocess.PIPE,
            text=True,
            cwd=repo_root,
        )
        proc.check_returncode()
        return proc.stdout

    old_versions = parse_package_table(git_show(base_ref, "Installed-Software.md"))
    if head_ref:
        new_versions = parse_package_table(git_show(head_ref, "Installed-Software.md"))
    else:
        new_versions = {pkg.name: pkg.version for pkg in list_packages(repo_root)}

    changed_packages: list[ChangedPackage] = []

    for pkg_name in old_versions.keys() | new_versions.keys():
        old_version = old_versions.get(pkg_name)
        new_version = new_versions.get(pkg_name)
        if old_version != new_version:
            changed_packages.append(ChangedPackage(pkg_name, old_version, new_version))

    changed_packages.sort(key=lambda pkg: pkg.name)
    return changed_packages

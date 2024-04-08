from catkin_pkg.packages import find_packages

from collections import defaultdict

def create_dependency_graph(packages):
    dependency_graph = defaultdict(list)

    for package, dependencies in packages.items():
        for dependency in dependencies:
            dependency_graph[dependency].append(package)

    return dependency_graph

def topological_sort_for_specific_packages(dependency_graph, known_packages):
    visited = set()
    result = []

    def dfs(package):
        if package not in visited and package in known_packages:
            visited.add(package)
            for dependency in dependency_graph[package]:
                dfs(dependency)
            result.append(package)

    for package in known_packages:
        if package not in visited:
            dfs(package)

    return result[::-1]


def find_packages_sorted(src_path, ros_distro):
    print("ros_distro:", ros_distro)

    pkgs_dict = find_packages(src_path)

    # print(pkgs_dict)

    packages = {}
    packages_path = {}
    specified_packages = []

    for path, pkg in pkgs_dict.items():
        # print(path)
        pkg.evaluate_conditions({
                'ROS_VERSION': '2',
                'ROS_DISTRO': ros_distro,
                'ROS_PYTHON_VERSION': '3',
                })
        depends = [
            dep for dep in (pkg.run_depends + pkg.buildtool_export_depends)
            if dep.evaluated_condition is not False]
        build_depends = [
            dep for dep in (pkg.build_depends + pkg.buildtool_depends)
            if dep.evaluated_condition is not False]
        # print(depends)
        # print(build_depends)
        keys = depends + build_depends
        keys = [k.name for k in keys]
        keys = list(set(keys))
        # print(keys)
        packages[pkg.name] = keys
        specified_packages.append(pkg.name)
        packages_path[pkg.name] = path

    dependency_graph = create_dependency_graph(packages)
    sorted_packages = topological_sort_for_specific_packages(dependency_graph, specified_packages)
    print("排序结果:", sorted_packages)

    return {package: packages_path[package] for package in sorted_packages}

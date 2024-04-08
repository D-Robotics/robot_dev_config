import os
import sys
import re
import subprocess
import shutil
import time

from packages_sort import find_packages_sorted

ROSDISTRO="humble"

def process_bash_command(bash_command, time_out=None):
    process = subprocess.Popen(
        bash_command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    print(f"bash_command: {bash_command}")
    # 获取命令的标准输出和标准错误输出
    stdout, stderr = process.communicate(timeout=time_out)
    # 打印输出结果
    print("标准输出：")
    print(stdout.decode())
    print("标准错误输出：")
    print(stderr.decode())

    # 获取命令的返回码
    return_code = process.returncode
    print("返回码:", return_code)
    return return_code, stdout.decode(), stderr.decode() 

def rosdep_update():
    update_command = f"rosdep update --rosdistro={ROSDISTRO}"
    process_bash_command(update_command, 30)

def rosdep_install(src_path):
    install_command = f"rosdep install --from-paths {src_path} --ignore-src -y --rosdistro {ROSDISTRO}"
    process_bash_command(install_command)

def bloom_generate():
    generate_command = f"bloom-generate rosdebian --ros-distro {ROSDISTRO}"
    process_bash_command(generate_command, 50)

def bloom_build():
    build_command = f"fakeroot debian/rules binary"
    return process_bash_command(build_command)

def set_token():
    command = f"echo $TOKEN"
    process_bash_command(command)

def trosdep_add(package_name):
    add_command = f"trosdep-add {package_name}"
    process_bash_command(add_command)

def trosdep_delete(package_name):
    delete_command = f"trosdep-delete {package_name}"
    process_bash_command(delete_command)

from catkin_pkg.topological_order import topological_order

def main():
    src_path = sys.argv[1]
    num_args = len(sys.argv) - 1
    select_flase = False
    if (num_args == 2):
        select_package = sys.argv[2]
        select_flase = True
        print(select_package)
    # rosdep_update()
    # rosdep_install(src_path)
    current_directory = os.getcwd()
    src_path = os.path.join(current_directory, src_path)
    out_path = os.path.join(current_directory, '../temp')
    deb_out_path = os.path.join(current_directory, '../temp')

    if not os.path.exists(out_path):
        os.makedirs(out_path)
    if not os.path.exists(deb_out_path):
        os.makedirs(deb_out_path)

    packages = find_packages_sorted(src_path, ROSDISTRO)
    # 检查是否不包含 'package4'
    if select_flase == True:
        if not any(temp_p == select_package for temp_p, _ in packages.items()):
            print(select_package,'不存在')
            return
    for package, path in packages.items():
        print(package, path)
        if select_flase == True:
            if select_package != package:
                continue
        os.chdir(os.path.join(src_path, path))
        # rosdep_update()
        # time.sleep(1)
        bloom_generate()
        status, stdout, stderr = bloom_build()
        if status:
            break

        package_ddeb = None
        result_ddeb = re.search( r"mv .*? ([^']+\.ddeb)", stdout)
        if result_ddeb:
            package_ddeb = result_ddeb.group(1)
            print("Package DDEB:", package_ddeb)

        pattern = r"dpkg-deb: building package '(.*?)' in '(.*?)'"
        matches = re.search(pattern, stdout)
        if matches:
            package_name = matches.group(1)
            package_deb = matches.group(2)
            print("Package Name:", package_name)
            print("Package Deb:", package_deb)
            local_install_command = f"dpkg -i {package_deb}"
            process_bash_command(local_install_command)
            match = re.match(r"\.\./(.+)_(\d+\.\d+\.\d+)-(\w+)\.(\d{8}\.\d{6})_(\w+)\.deb$", package_deb)
            date_time = ''
            if match:
                date_time = match.group(4)
            package_out_path = os.path.join(out_path, package_name+'.'+date_time)
            os.mkdir(package_out_path)
            shutil.copy(package_deb, deb_out_path)
            shutil.move(package_deb, package_out_path)
            if os.path.exists('debian'):
                shutil.move('debian', package_out_path)
            if os.path.exists('.obj-aarch64-linux-gnu'):
                shutil.move('.obj-aarch64-linux-gnu', package_out_path)
            if os.path.exists(f'{package}.egg-info'):
                shutil.move(f'{package}.egg-info', package_out_path)
            if os.path.exists('.pybuild'):
                shutil.move('.pybuild', package_out_path)
            if package_ddeb:
                shutil.move(package_ddeb, package_out_path)
        else:
            print("未找到匹配的日志行")

        # trosdep_add(package)
        process_bash_command("touch COLCON_IGNORE")
        time.sleep(1)

if __name__ == "__main__":
    main()
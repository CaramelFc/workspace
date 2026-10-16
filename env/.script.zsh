# 冒号分隔的环境变量（PATH / LD_LIBRARY_PATH / LIBRARY_PATH / PYTHONPATH / CPATH ...）
# 增删工具，仅依赖 zsh（由 .zshrc source）
#
# 特性：条目前置自动去重、空值安全（不会产生前导/尾随/重复冒号）、
#       路径含空格安全、比较时忽略尾部 "/"

# _env_var_add <变量名> <条目>：将条目前置，已存在则移到最前而不重复
_env_var_add() {
	emulate -L zsh
	local varname=$1 entry=$2
	[[ -n $entry ]] || return 0
	entry=${entry%/}
	[[ -n $entry ]] || entry=/

	local -a parts
	parts=($entry ${(s.:.)${(P)varname}})
	parts=(${(u)parts:#})
	export "$varname=${(j.:.)parts}"
}

# _env_var_del <变量名> <条目>：删除所有匹配条目，删空后 unset 该变量
_env_var_del() {
	emulate -L zsh
	local varname=$1 entry=$2 e norm
	[[ -n $entry ]] || return 0
	entry=${entry%/}
	[[ -n $entry ]] || entry=/

	local -a parts result
	parts=(${(s.:.)${(P)varname}})
	parts=(${parts:#})
	for e in "${parts[@]}"; do
		norm=${e%/}
		[[ -n $norm ]] || norm=/
		if [[ $norm != $entry ]]; then
			result+=("$e")
		fi
	done

	if (( $#result )); then
		export "$varname=${(j.:.)result}"
	else
		unset "$varname"
	fi
}

# 兼容旧函数名
_add_env_var()    { _env_var_add "$@" }
_delete_env_var() { _env_var_del "$@" }

add_path() {
	[[ -d $1 ]] || return 0
	_env_var_add PATH "$1"
}

del_path() {
	_env_var_del PATH "$1"
}

_add_cpath() {
	[[ -d $1 ]] || return 0
	_env_var_add CPATH "$1"
}
_del_cpath() {
	_env_var_del CPATH "$1"
}

# 参数本身是库目录（add_3rdparty 传入的是 .../lib、.../lib64）
_add_library_path() {
	[[ -d $1 ]] || return 0
	_env_var_add LD_LIBRARY_PATH "$1"
	_env_var_add LIBRARY_PATH "$1"
}
_del_library_path() {
	_env_var_del LD_LIBRARY_PATH "$1"
	_env_var_del LIBRARY_PATH "$1"
}

add_3rdparty() {
	_add_path         "$1/bin"
	_add_cpath        "$1/include"
	_add_library_path "$1/lib"
	_add_library_path "$1/lib64"
}
del_3rdparty() {
	_del_path         "$1/bin"
	_del_cpath        "$1/include"
	_del_library_path "$1/lib"
	_del_library_path "$1/lib64"
}

add_py_path() {
	[[ -d $1 ]] || return 0
	_env_var_add PYTHONPATH "$1"
}
del_py_path() {
	_env_var_del PYTHONPATH "$1"
}

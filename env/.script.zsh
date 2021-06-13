# param1 env_var
# param2 var_name
function _add_env_var(){
    res=`eval echo "$"$2`
    export "$2"=$1:$res
}

# param1 env_var
# param2 var_name
function _delete_env_var(){
    res=`eval echo "$"$2`
    #echo $res
    param_lists=${${res}//:/ }
    #echo $param_lists
    tmp_var=""
    for elem in `echo $param_lists`
    do
        if [ "$elem" != "$1" ];then
            tmp_var=$tmp_var:$elem
        fi
    done
    #echo $tmp_var
    export "$2"=$tmp_var
}

function _add_cpath(){
    if [ -d $1 ];then
        _add_env_var $1 CPATH
    fi
}

function _del_cpath(){
    _delete_env_var $1 CPATH
}

function _add_path(){
    if [ -d $1 ];then
        _add_env_var $1 PATH
    fi
}

function _del_path(){
    _delete_env_var $1 PATH
}

function _add_library_path(){
    if [ -d $1 ];then
        _add_env_var $1 LD_LIBRARY_PATH
        _add_env_var $1 LIBRARY_PATH
    fi
}

function _del_library_path(){
    _delete_env_var $1 LD_LIBRARY_PATH
    _delete_env_var $1 LIBRARY_PATH
}

function add_3rdparty(){
    _add_path $1/bin
    _add_cpath $1/include
    _add_library_path $1/lib
    _add_library_path $1/lib64
}

function del_3rdparty(){
    _del_path $1/bin
    _del_cpath $1/include
    _del_library_path $1/lib
    _del_library_path $1/lib64
}

function add_py_path(){
    if [ -d $1 ];then
        _add_env_var $1 PYTHONPATH
    fi
}

function del_py_path(){
    _delete_env_var $1 PYTHONPATH
}

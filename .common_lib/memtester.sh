
MEMTESTER=memtester-4.5.1
MEMTESTER_INSTALL=${OUTPUT_PATH}/${MEMTESTER}

download_memtester () {
    cd ${BASE}/compressed
    tget https://pyropus.ca./software/memtester/old-versions/${MEMTESTER}.tar.gz
}

mk_memtester () {
    mkdir -p ${MEMTESTER_INSTALL}

    cd $CODE_PATH/${MEMTESTER}
    ${_CC} memtester.c  tests.c  -o ${MEMTESTER_INSTALL}/memtester
}

function make_memtester ()
{
    download_memtester  || return 1
    tar_package || return 1

    mk_memtester  || return 1
}


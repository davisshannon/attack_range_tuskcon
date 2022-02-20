rule pe_info
{ 
    meta:
        plugin = "hash, peinfo, hash_ssdeep"
        save = "True"
    strings:
        $MZ = "MZ"
    condition:
        $MZ at 0 and uint32(uint32(0x3C)) == 0x4550
}


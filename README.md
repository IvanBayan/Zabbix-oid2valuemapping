# Zabbix-oid2valuemapping

Since Zabbix 3.0 it's possible to import/export value mappings in XML format or
manage it via API. That script create mappings in XML format which you could
import in Zabbix, all that you need - specify OID.
## Installation
Perl:
You need next perl modules: SNMP, XML::Simple
In debian/ubuntu (tested on Jessie 8.3 and Trusty 14.04 respectively) you need
next packages: libsnmp-perl and libxml-simple-perl

SNMP:
You need to have properly configured SNMP. First check that snmp 'know' about
OID in which you are interesting for.
For example:
```
snmpget -v 2c -c public localhost   ifType.1
IF-MIB::ifType.1 = INTEGER: ethernetCsmacd(6)
```
Here you see that host return integer value 6 that was mapped to
'ethernetCsmacd'.

You can specify additional MIB directory, but i didn't test it, sorry.
## Usage
```bash
oid2valuemapping.pl --oid OID::to_map [--name values_mappings_name] [--mibs-dir /path/to/mibs] [--dir] [--help] 
```
--oid - is mandatory option, you can specify it by name or in numerical form
    so for example IF-MIB::ifType, ifType or .1.3.6.1.2.1.2.2.1.3 will work in
    same way
    
--name - you can choose the name for your mapping, if not specified textual
    convention name or label will be used
    
--mibs-dir - you can add additional MIBs dir

--dir - by default script will write XML document right on your screen, if you
    will specify 'dir' option, script will create file in that directory

    
Examples:
```
oid2valuemapping.pl --oid .1.3.6.1.2.1.11.30
```

Will print on display next xml:
```xml
<?xml version='1.0' standalone='yes'?>
<zabbix_export>
  <date>2016-08-25T14:50:03Z</date>
  <value_maps>
    <value_map>
      <name>snmpEnableAuthenTraps</name>
      <mappings>
        <mapping>
          <newvalue>disabled</newvalue>
          <value>2</value>
        </mapping>
        <mapping>
          <newvalue>enabled</newvalue>
          <value>1</value>
        </mapping>
      </mappings>
    </value_map>
  </value_maps>
  <version>3.0</version>
</zabbix_export>
```
```
oid2valuemapping.pl --oid .1.3.6.1.2.1.11.30 --dir /tmp
```
Will write same xml in /tmp/snmpEnableAuthenTraps.xml

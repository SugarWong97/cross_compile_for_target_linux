#/** @file         make.sh
#*  @author       Schips
#*  @date         2020-10-28 23:22:53
#*  @version      v1.0
#*  @copyright    Copyright By Schips, All Rights Reserved
#*
#**********************************************************
#*
#*  @par 修改日志:
#*  <table>
#*  <tr><th>Date       <th>Version   <th>Author    <th>Description
#*  <tr><td>2020-10-28 <td>1.0       <td>Schips    <td>创建初始版本
#*  </table>
#*
#**********************************************************
#*/

#!/bin/sh

source ../.common || return 1

make_e2fsprogs || echo "Err"

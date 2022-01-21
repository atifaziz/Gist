# Copyright (c) 2022 Atif Aziz. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

[CmdletBinding()]
param ()

Get-Command |
    Select-Object -ExpandProperty Name |
    Where-Object { $_ -cmatch '^[A-Z][a-z]+-[A-Z][A-Za-z0-9]*$' } |
    ForEach-Object { ($_ -split '-', 2)[0] } |
    Select-Object -Unique |
    Sort-Object

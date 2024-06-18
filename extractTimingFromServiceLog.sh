#! /bin/bash
##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
##  (C) Copyright 2018-2024 Modeling Value Group B.V. (http://modelingvalue.org)                                         ~
##                                                                                                                       ~
##  Licensed under the GNU Lesser General Public License v3.0 (the 'License'). You may not use this file except in       ~
##  compliance with the License. You may obtain a copy of the License at: https://choosealicense.com/licenses/lgpl-3.0   ~
##  Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on  ~
##  an 'AS IS' BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the   ~
##  specific language governing permissions and limitations under the License.                                           ~
##                                                                                                                       ~
##  Maintainers:                                                                                                         ~
##      Wim Bast, Tom Brus                                                                                               ~
##                                                                                                                       ~
##  Contributors:                                                                                                        ~
##      Ronald Krijgsheld ✝, Arjan Kok, Carel Bast                                                                       ~
## --------------------------------------------------------------------------------------------------------------------- ~
##  In Memory of Ronald Krijgsheld, 1972 - 2023                                                                          ~
##      Ronald was suddenly and unexpectedly taken from us. He was not only our long-term colleague and team member      ~
##      but also our friend. "He will live on in many of the lines of code you see below."                               ~
##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

HDR='json,e1,m2cds,e2,cds2m,e3,total'

echo "$HDR"
cat $0 \
    | sed '1,/^exit 0/d' \
    | sed 's/^... .. ..:..:.. ip-[^ ]* web.[0-9]*.: //' \
    | egrep '( took |^===)' \
    | sed 's/.*~~[^_]*_//' \
    | sed 's/^=== ..../overall /;s/ |.*//' \
    | sed -e ':a' -e '$!N;s/\nm2cds/ m2cds/;ta' -e 'P;D' \
    | sed -e ':a' -e '$!N;s/\ncds2m/ cds2m/;ta' -e 'P;D' \
    | sed -e ':a' -e '$!N;s/\noverall/ overall/;ta' -e 'P;D' \
    | sed -E '/(makeBaseModels|makeExample)/d' \
    | sed 's/jsonIn[^(]*(m.r=//' \
    | sed 's/) m2cds[^(]*(m.r=//' \
    | sed 's/) cds2m[^(]*(m.r=//' \
    | sed 's/) overall//' \
    | sed 's/ms//' \
    | sed 's/^ *//;s/ *$//' \
    | sed 's/+//g' \
    | sed -E 's/ +/,/g' \



exit 0

   ,     #_
   ~\_  ####_        Amazon Linux 2023
  ~~  \_#####\
  ~~     \###|
  ~~       \#/ ___   https://aws.amazon.com/linux/amazon-linux-2023
   ~~       V~' '->
    ~~~         /
      ~~._.   _/
         _/ _/
       _/m/'
[root@ip-172-31-47-193 ~]#
[root@ip-172-31-47-193 ~]#
[root@ip-172-31-47-193 ~]#
[root@ip-172-31-47-193 ~]#
[root@ip-172-31-47-193 ~]#
[root@ip-172-31-47-193 ~]#
[root@ip-172-31-47-193 ~]#
[root@ip-172-31-47-193 ~]# htop
[root@ip-172-31-47-193 ~]# htop
[root@ip-172-31-47-193 ~]#
[root@ip-172-31-47-193 ~]#
[root@ip-172-31-47-193 ~]#
[root@ip-172-31-47-193 ~]#
[root@ip-172-31-47-193 ~]#
[root@ip-172-31-47-193 ~]#
[root@ip-172-31-47-193 ~]#
[root@ip-172-31-47-193 ~]# htop
[root@ip-172-31-47-193 ~]# htop
[root@ip-172-31-47-193 ~]# vi /var/log/web.stdout.log
[root@ip-172-31-47-193 ~]# tail -f /var/log/web.stdout.log
Feb 23 11:50:09 ip-172-31-47-193 web[3039]: TRACE_ONE_SHOT:  CACHE-SKIP    OSS__Venetoclax__CLL                      -  ~~action00_makeBaseModels
Feb 23 11:50:09 ip-172-31-47-193 web[3039]: TRACE_ONE_SHOT:  >>ACTION      OSS__Venetoclax__CLL                      -  ~~action10_jsonIn
Feb 23 11:50:09 ip-172-31-47-193 web[3039]: TRACE_ONE_SHOT:  <<ACTION      OSS__Venetoclax__CLL                      -  ~~action10_jsonIn         took   137 ms (m+r=   53 +    83)
Feb 23 11:50:09 ip-172-31-47-193 web[3039]: TRACE_ONE_SHOT:  >>ACTION      OSS__Venetoclax__CLL                      -  ~~action20_m2cds
Feb 23 11:50:14 ip-172-31-47-193 web[3039]: TRACE_ONE_SHOT:  <<ACTION      OSS__Venetoclax__CLL                      -  ~~action20_m2cds          took  4835 ms (m+r=   11 +  4824)
Feb 23 11:50:14 ip-172-31-47-193 web[3039]: TRACE_ONE_SHOT:  >>ACTION      OSS__Venetoclax__CLL                      -  ~~action30_cds2m
Feb 23 11:50:14 ip-172-31-47-193 web[3039]: TRACE_ONE_SHOT:  <<ACTION      OSS__Venetoclax__CLL                      -  ~~action30_cds2m          took   367 ms (m+r=  132 +   234)
Feb 23 11:50:14 ip-172-31-47-193 web[3039]: TRACE_ONE_SHOT: DONE           OSS__Venetoclax__CLL                      -  duration= 5343 ms
Feb 23 11:50:14 ip-172-31-47-193 web[3039]: TRACE: ContextPoolPool: [http-nio-9999-exec-7     ] done                     : idle/busy=  2/  0:    5 gets (   5 immediates    0 waits        0 ms totalWait,        0 ms max-wait)
Feb 23 11:50:14 ip-172-31-47-193 web[3039]: === [dt=    5440 ms | free=  45 MB | tot= 114 MB | max= 798 MB]: /Venetoclax/1.0/CLL

Feb 23 11:54:14 ip-172-31-47-193 web[3039]: TRACE: ContextPoolPool: [http-nio-9999-exec-8     ] get                      : idle/busy=  2/  0:    6 gets (   5 immediates    0 waits        0 ms totalWait,        0 ms max-wait)
Feb 23 11:54:14 ip-172-31-47-193 web[3039]: TRACE: ContextPoolPool: [http-nio-9999-exec-8     ] waited      0 ms         : idle/busy=  1/  1:    6 gets (   6 immediates    0 waits        0 ms totalWait,        0 ms max-wait)
Feb 23 11:54:14 ip-172-31-47-193 web[3039]: TRACE_ONE_SHOT: START          OSS__Venetoclax__CLL                      -  #actions=4
Feb 23 11:54:14 ip-172-31-47-193 web[3039]: TRACE_ONE_SHOT:  CACHE-SKIP    OSS__Venetoclax__CLL                      -  ~~action00_makeBaseModels
Feb 23 11:54:14 ip-172-31-47-193 web[3039]: TRACE_ONE_SHOT:  >>ACTION      OSS__Venetoclax__CLL                      -  ~~action10_jsonIn
Feb 23 11:54:14 ip-172-31-47-193 web[3039]: TRACE_ONE_SHOT:  <<ACTION      OSS__Venetoclax__CLL                      -  ~~action10_jsonIn         took   110 ms (m+r=   45 +    65)
Feb 23 11:54:14 ip-172-31-47-193 web[3039]: TRACE_ONE_SHOT:  >>ACTION      OSS__Venetoclax__CLL                      -  ~~action20_m2cds
Feb 23 11:54:19 ip-172-31-47-193 web[3039]: TRACE_ONE_SHOT:  <<ACTION      OSS__Venetoclax__CLL                      -  ~~action20_m2cds          took  5340 ms (m+r=   15 +  5325)
Feb 23 11:54:19 ip-172-31-47-193 web[3039]: TRACE_ONE_SHOT:  >>ACTION      OSS__Venetoclax__CLL                      -  ~~action30_cds2m
Feb 23 11:54:20 ip-172-31-47-193 web[3039]: TRACE_ONE_SHOT:  <<ACTION      OSS__Venetoclax__CLL                      -  ~~action30_cds2m          took   410 ms (m+r=  156 +   254)
Feb 23 11:54:20 ip-172-31-47-193 web[3039]: TRACE_ONE_SHOT: DONE           OSS__Venetoclax__CLL                      -  duration= 5866 ms
Feb 23 11:54:20 ip-172-31-47-193 web[3039]: TRACE: ContextPoolPool: [http-nio-9999-exec-8     ] done                     : idle/busy=  2/  0:    6 gets (   6 immediates    0 waits        0 ms totalWait,        0 ms max-wait)
Feb 23 11:54:20 ip-172-31-47-193 web[3039]: === [dt=    5959 ms | free=  25 MB | tot= 114 MB | max= 798 MB]: /Venetoclax/1.0/CLL
Feb 23 11:54:45 ip-172-31-47-193 web[3039]: TRACE: ContextPoolPool: [http-nio-9999-exec-9     ] get                      : idle/busy=  2/  0:    7 gets (   6 immediates    0 waits        0 ms totalWait,        0 ms max-wait)
Feb 23 11:54:45 ip-172-31-47-193 web[3039]: TRACE: ContextPoolPool: [http-nio-9999-exec-9     ] waited      0 ms         : idle/busy=  1/  1:    7 gets (   7 immediates    0 waits        0 ms totalWait,        0 ms max-wait)
Feb 23 11:54:45 ip-172-31-47-193 web[3039]: TRACE_ONE_SHOT: START          OSS__Venetoclax__CLL                      -  #actions=4
Feb 23 11:54:45 ip-172-31-47-193 web[3039]: TRACE_ONE_SHOT:  CACHE-SKIP    OSS__Venetoclax__CLL                      -  ~~action00_makeBaseModels
Feb 23 11:54:45 ip-172-31-47-193 web[3039]: TRACE_ONE_SHOT:  >>ACTION      OSS__Venetoclax__CLL                      -  ~~action10_jsonIn
Feb 23 11:54:45 ip-172-31-47-193 web[3039]: TRACE_ONE_SHOT:  <<ACTION      OSS__Venetoclax__CLL                      -  ~~action10_jsonIn         took   127 ms (m+r=   49 +    78)
Feb 23 11:54:45 ip-172-31-47-193 web[3039]: TRACE_ONE_SHOT:  >>ACTION      OSS__Venetoclax__CLL                      -  ~~action20_m2cds
Feb 23 11:54:51 ip-172-31-47-193 web[3039]: TRACE_ONE_SHOT:  <<ACTION      OSS__Venetoclax__CLL                      -  ~~action20_m2cds          took  5335 ms (m+r=   13 +  5321)
Feb 23 11:54:51 ip-172-31-47-193 web[3039]: TRACE_ONE_SHOT:  >>ACTION      OSS__Venetoclax__CLL                      -  ~~action30_cds2m
Feb 23 11:54:51 ip-172-31-47-193 web[3039]: TRACE_ONE_SHOT:  <<ACTION      OSS__Venetoclax__CLL                      -  ~~action30_cds2m          took   383 ms (m+r=  129 +   254)
Feb 23 11:54:51 ip-172-31-47-193 web[3039]: TRACE_ONE_SHOT: DONE           OSS__Venetoclax__CLL                      -  duration= 5849 ms
Feb 23 11:54:51 ip-172-31-47-193 web[3039]: TRACE: ContextPoolPool: [http-nio-9999-exec-9     ] done                     : idle/busy=  2/  0:    7 gets (   7 immediates    0 waits        0 ms totalWait,        0 ms max-wait)
Feb 23 11:54:51 ip-172-31-47-193 web[3039]: === [dt=    5948 ms | free=  61 MB | tot= 114 MB | max= 798 MB]: /Venetoclax/1.0/CLL
Feb 23 11:54:53 ip-172-31-47-193 web[3039]: TRACE: ContextPoolPool: [http-nio-9999-exec-10    ] get                      : idle/busy=  2/  0:    8 gets (   7 immediates    0 waits        0 ms totalWait,        0 ms max-wait)
Feb 23 11:54:53 ip-172-31-47-193 web[3039]: TRACE: ContextPoolPool: [http-nio-9999-exec-10    ] waited      0 ms         : idle/busy=  1/  1:    8 gets (   8 immediates    0 waits        0 ms totalWait,        0 ms max-wait)
Feb 23 11:54:53 ip-172-31-47-193 web[3039]: TRACE_ONE_SHOT: START          OSS__Venetoclax__CLL                      -  #actions=4
Feb 23 11:54:53 ip-172-31-47-193 web[3039]: TRACE_ONE_SHOT:  CACHE-SKIP    OSS__Venetoclax__CLL                      -  ~~action00_makeBaseModels
Feb 23 11:54:53 ip-172-31-47-193 web[3039]: TRACE_ONE_SHOT:  >>ACTION      OSS__Venetoclax__CLL                      -  ~~action10_jsonIn
Feb 23 11:54:53 ip-172-31-47-193 web[3039]: TRACE_ONE_SHOT:  <<ACTION      OSS__Venetoclax__CLL                      -  ~~action10_jsonIn         took   105 ms (m+r=   40 +    64)
Feb 23 11:54:53 ip-172-31-47-193 web[3039]: TRACE_ONE_SHOT:  >>ACTION      OSS__Venetoclax__CLL                      -  ~~action20_m2cds
Feb 23 11:54:57 ip-172-31-47-193 web[3039]: TRACE_ONE_SHOT:  <<ACTION      OSS__Venetoclax__CLL                      -  ~~action20_m2cds          took  4664 ms (m+r=   11 +  4652)
Feb 23 11:54:57 ip-172-31-47-193 web[3039]: TRACE_ONE_SHOT:  >>ACTION      OSS__Venetoclax__CLL                      -  ~~action30_cds2m
Feb 23 11:54:58 ip-172-31-47-193 web[3039]: TRACE_ONE_SHOT:  <<ACTION      OSS__Venetoclax__CLL                      -  ~~action30_cds2m          took   393 ms (m+r=  122 +   270)
Feb 23 11:54:58 ip-172-31-47-193 web[3039]: TRACE_ONE_SHOT: DONE           OSS__Venetoclax__CLL                      -  duration= 5167 ms
Feb 23 11:54:58 ip-172-31-47-193 web[3039]: TRACE: ContextPoolPool: [http-nio-9999-exec-10    ] done                     : idle/busy=  2/  0:    8 gets (   8 immediates    0 waits        0 ms totalWait,        0 ms max-wait)
Feb 23 11:54:58 ip-172-31-47-193 web[3039]: === [dt=    5263 ms | free=  33 MB | tot= 114 MB | max= 798 MB]: /Venetoclax/1.0/CLL
Feb 23 11:54:59 ip-172-31-47-193 web[3039]: TRACE: ContextPoolPool: [http-nio-9999-exec-1     ] get                      : idle/busy=  2/  0:    9 gets (   8 immediates    0 waits        0 ms totalWait,        0 ms max-wait)
Feb 23 11:54:59 ip-172-31-47-193 web[3039]: TRACE: ContextPoolPool: [http-nio-9999-exec-1     ] waited      0 ms         : idle/busy=  1/  1:    9 gets (   9 immediates    0 waits        0 ms totalWait,        0 ms max-wait)
Feb 23 11:54:59 ip-172-31-47-193 web[3039]: TRACE_ONE_SHOT: START          OSS__Venetoclax__CLL                      -  #actions=4
Feb 23 11:54:59 ip-172-31-47-193 web[3039]: TRACE_ONE_SHOT:  CACHE-SKIP    OSS__Venetoclax__CLL                      -  ~~action00_makeBaseModels
Feb 23 11:54:59 ip-172-31-47-193 web[3039]: TRACE_ONE_SHOT:  >>ACTION      OSS__Venetoclax__CLL                      -  ~~action10_jsonIn
Feb 23 11:55:00 ip-172-31-47-193 web[3039]: TRACE_ONE_SHOT:  <<ACTION      OSS__Venetoclax__CLL                      -  ~~action10_jsonIn         took   124 ms (m+r=   38 +    86)
Feb 23 11:55:00 ip-172-31-47-193 web[3039]: TRACE_ONE_SHOT:  >>ACTION      OSS__Venetoclax__CLL                      -  ~~action20_m2cds
Feb 23 11:55:05 ip-172-31-47-193 web[3039]: TRACE_ONE_SHOT:  <<ACTION      OSS__Venetoclax__CLL                      -  ~~action20_m2cds          took  5289 ms (m+r=   40 +  5249)
Feb 23 11:55:05 ip-172-31-47-193 web[3039]: TRACE_ONE_SHOT:  >>ACTION      OSS__Venetoclax__CLL                      -  ~~action30_cds2m
Feb 23 11:55:05 ip-172-31-47-193 web[3039]: TRACE_ONE_SHOT:  <<ACTION      OSS__Venetoclax__CLL                      -  ~~action30_cds2m          took   392 ms (m+r=  141 +   250)
Feb 23 11:55:05 ip-172-31-47-193 web[3039]: TRACE_ONE_SHOT: DONE           OSS__Venetoclax__CLL                      -  duration= 5809 ms
Feb 23 11:55:05 ip-172-31-47-193 web[3039]: TRACE: ContextPoolPool: [http-nio-9999-exec-1     ] done                     : idle/busy=  2/  0:    9 gets (   9 immediates    0 waits        0 ms totalWait,        0 ms max-wait)
Feb 23 11:55:05 ip-172-31-47-193 web[3039]: === [dt=    5906 ms | free=  53 MB | tot= 114 MB | max= 798 MB]: /Venetoclax/1.0/CLL
Feb 23 11:55:06 ip-172-31-47-193 web[3039]: TRACE: ContextPoolPool: [http-nio-9999-exec-2     ] get                      : idle/busy=  2/  0:   10 gets (   9 immediates    0 waits        0 ms totalWait,        0 ms max-wait)
Feb 23 11:55:06 ip-172-31-47-193 web[3039]: TRACE: ContextPoolPool: [http-nio-9999-exec-2     ] waited      0 ms         : idle/busy=  1/  1:   10 gets (  10 immediates    0 waits        0 ms totalWait,        0 ms max-wait)
Feb 23 11:55:06 ip-172-31-47-193 web[3039]: TRACE_ONE_SHOT: START          OSS__Venetoclax__CLL                      -  #actions=4
Feb 23 11:55:06 ip-172-31-47-193 web[3039]: TRACE_ONE_SHOT:  CACHE-SKIP    OSS__Venetoclax__CLL                      -  ~~action00_makeBaseModels
Feb 23 11:55:06 ip-172-31-47-193 web[3039]: TRACE_ONE_SHOT:  >>ACTION      OSS__Venetoclax__CLL                      -  ~~action10_jsonIn
Feb 23 11:55:07 ip-172-31-47-193 web[3039]: TRACE_ONE_SHOT:  <<ACTION      OSS__Venetoclax__CLL                      -  ~~action10_jsonIn         took   102 ms (m+r=   38 +    63)
Feb 23 11:55:07 ip-172-31-47-193 web[3039]: TRACE_ONE_SHOT:  >>ACTION      OSS__Venetoclax__CLL                      -  ~~action20_m2cds
Feb 23 11:55:12 ip-172-31-47-193 web[3039]: TRACE_ONE_SHOT:  <<ACTION      OSS__Venetoclax__CLL                      -  ~~action20_m2cds          took  4991 ms (m+r=   16 +  4975)
Feb 23 11:55:12 ip-172-31-47-193 web[3039]: TRACE_ONE_SHOT:  >>ACTION      OSS__Venetoclax__CLL                      -  ~~action30_cds2m
Feb 23 11:55:12 ip-172-31-47-193 web[3039]: TRACE_ONE_SHOT:  <<ACTION      OSS__Venetoclax__CLL                      -  ~~action30_cds2m          took   406 ms (m+r=  135 +   271)
Feb 23 11:55:12 ip-172-31-47-193 web[3039]: TRACE_ONE_SHOT: DONE           OSS__Venetoclax__CLL                      -  duration= 5504 ms
Feb 23 11:55:12 ip-172-31-47-193 web[3039]: TRACE: ContextPoolPool: [http-nio-9999-exec-2     ] done                     : idle/busy=  2/  0:   10 gets (  10 immediates    0 waits        0 ms totalWait,        0 ms max-wait)
Feb 23 11:55:12 ip-172-31-47-193 web[3039]: === [dt=    5597 ms | free=  14 MB | tot= 114 MB | max= 798 MB]: /Venetoclax/1.0/CLL
Feb 23 11:55:13 ip-172-31-47-193 web[3039]: TRACE: ContextPoolPool: [http-nio-9999-exec-3     ] get                      : idle/busy=  2/  0:   11 gets (  10 immediates    0 waits        0 ms totalWait,        0 ms max-wait)
Feb 23 11:55:13 ip-172-31-47-193 web[3039]: TRACE: ContextPoolPool: [http-nio-9999-exec-3     ] waited      0 ms         : idle/busy=  1/  1:   11 gets (  11 immediates    0 waits        0 ms totalWait,        0 ms max-wait)
Feb 23 11:55:13 ip-172-31-47-193 web[3039]: TRACE_ONE_SHOT: START          OSS__Venetoclax__CLL                      -  #actions=4
Feb 23 11:55:13 ip-172-31-47-193 web[3039]: TRACE_ONE_SHOT:  CACHE-SKIP    OSS__Venetoclax__CLL                      -  ~~action00_makeBaseModels
Feb 23 11:55:13 ip-172-31-47-193 web[3039]: TRACE_ONE_SHOT:  >>ACTION      OSS__Venetoclax__CLL                      -  ~~action10_jsonIn
Feb 23 11:55:14 ip-172-31-47-193 web[3039]: TRACE_ONE_SHOT:  <<ACTION      OSS__Venetoclax__CLL                      -  ~~action10_jsonIn         took    99 ms (m+r=   39 +    60)
Feb 23 11:55:14 ip-172-31-47-193 web[3039]: TRACE_ONE_SHOT:  >>ACTION      OSS__Venetoclax__CLL                      -  ~~action20_m2cds
Feb 23 11:55:19 ip-172-31-47-193 web[3039]: TRACE_ONE_SHOT:  <<ACTION      OSS__Venetoclax__CLL                      -  ~~action20_m2cds          took  5108 ms (m+r=   11 +  5096)
Feb 23 11:55:19 ip-172-31-47-193 web[3039]: TRACE_ONE_SHOT:  >>ACTION      OSS__Venetoclax__CLL                      -  ~~action30_cds2m
Feb 23 11:55:19 ip-172-31-47-193 web[3039]: TRACE_ONE_SHOT:  <<ACTION      OSS__Venetoclax__CLL                      -  ~~action30_cds2m          took   368 ms (m+r=  124 +   243)
Feb 23 11:55:19 ip-172-31-47-193 web[3039]: TRACE_ONE_SHOT: DONE           OSS__Venetoclax__CLL                      -  duration= 5578 ms
Feb 23 11:55:19 ip-172-31-47-193 web[3039]: TRACE: ContextPoolPool: [http-nio-9999-exec-3     ] done                     : idle/busy=  2/  0:   11 gets (  11 immediates    0 waits        0 ms totalWait,        0 ms max-wait)
Feb 23 11:55:19 ip-172-31-47-193 web[3039]: === [dt=    5667 ms | free=  39 MB | tot= 114 MB | max= 798 MB]: /Venetoclax/1.0/CLL
Feb 23 11:55:21 ip-172-31-47-193 web[3039]: TRACE: ContextPoolPool: [http-nio-9999-exec-4     ] get                      : idle/busy=  2/  0:   12 gets (  11 immediates    0 waits        0 ms totalWait,        0 ms max-wait)
Feb 23 11:55:21 ip-172-31-47-193 web[3039]: TRACE: ContextPoolPool: [http-nio-9999-exec-4     ] waited      0 ms         : idle/busy=  1/  1:   12 gets (  12 immediates    0 waits        0 ms totalWait,        0 ms max-wait)
Feb 23 11:55:21 ip-172-31-47-193 web[3039]: TRACE_ONE_SHOT: START          OSS__Venetoclax__CLL                      -  #actions=4
Feb 23 11:55:21 ip-172-31-47-193 web[3039]: TRACE_ONE_SHOT:  CACHE-SKIP    OSS__Venetoclax__CLL                      -  ~~action00_makeBaseModels
Feb 23 11:55:21 ip-172-31-47-193 web[3039]: TRACE_ONE_SHOT:  >>ACTION      OSS__Venetoclax__CLL                      -  ~~action10_jsonIn
Feb 23 11:55:21 ip-172-31-47-193 web[3039]: TRACE_ONE_SHOT:  <<ACTION      OSS__Venetoclax__CLL                      -  ~~action10_jsonIn         took   117 ms (m+r=   47 +    69)
Feb 23 11:55:21 ip-172-31-47-193 web[3039]: TRACE_ONE_SHOT:  >>ACTION      OSS__Venetoclax__CLL                      -  ~~action20_m2cds
Feb 23 11:55:25 ip-172-31-47-193 web[3039]: TRACE_ONE_SHOT:  <<ACTION      OSS__Venetoclax__CLL                      -  ~~action20_m2cds          took  4798 ms (m+r=   10 +  4787)
Feb 23 11:55:25 ip-172-31-47-193 web[3039]: TRACE_ONE_SHOT:  >>ACTION      OSS__Venetoclax__CLL                      -  ~~action30_cds2m
Feb 23 11:55:26 ip-172-31-47-193 web[3039]: TRACE_ONE_SHOT:  <<ACTION      OSS__Venetoclax__CLL                      -  ~~action30_cds2m          took   377 ms (m+r=  125 +   251)
Feb 23 11:55:26 ip-172-31-47-193 web[3039]: TRACE_ONE_SHOT: DONE           OSS__Venetoclax__CLL                      -  duration= 5295 ms
Feb 23 11:55:26 ip-172-31-47-193 web[3039]: TRACE: ContextPoolPool: [http-nio-9999-exec-4     ] done                     : idle/busy=  2/  0:   12 gets (  12 immediates    0 waits        0 ms totalWait,        0 ms max-wait)
Feb 23 11:55:26 ip-172-31-47-193 web[3039]: === [dt=    5387 ms | free=  29 MB | tot= 114 MB | max= 798 MB]: /Venetoclax/1.0/CLL
Feb 23 11:55:27 ip-172-31-47-193 web[3039]: TRACE: ContextPoolPool: [http-nio-9999-exec-5     ] get                      : idle/busy=  2/  0:   13 gets (  12 immediates    0 waits        0 ms totalWait,        0 ms max-wait)
Feb 23 11:55:27 ip-172-31-47-193 web[3039]: TRACE: ContextPoolPool: [http-nio-9999-exec-5     ] waited      0 ms         : idle/busy=  1/  1:   13 gets (  13 immediates    0 waits        0 ms totalWait,        0 ms max-wait)
Feb 23 11:55:27 ip-172-31-47-193 web[3039]: TRACE_ONE_SHOT: START          OSS__Venetoclax__CLL                      -  #actions=4
Feb 23 11:55:27 ip-172-31-47-193 web[3039]: TRACE_ONE_SHOT:  CACHE-SKIP    OSS__Venetoclax__CLL                      -  ~~action00_makeBaseModels
Feb 23 11:55:27 ip-172-31-47-193 web[3039]: TRACE_ONE_SHOT:  >>ACTION      OSS__Venetoclax__CLL                      -  ~~action10_jsonIn
Feb 23 11:55:27 ip-172-31-47-193 web[3039]: TRACE_ONE_SHOT:  <<ACTION      OSS__Venetoclax__CLL                      -  ~~action10_jsonIn         took   113 ms (m+r=   45 +    68)
Feb 23 11:55:27 ip-172-31-47-193 web[3039]: TRACE_ONE_SHOT:  >>ACTION      OSS__Venetoclax__CLL                      -  ~~action20_m2cds
Feb 23 11:55:32 ip-172-31-47-193 web[3039]: TRACE_ONE_SHOT:  <<ACTION      OSS__Venetoclax__CLL                      -  ~~action20_m2cds          took  5201 ms (m+r=   14 +  5186)
Feb 23 11:55:32 ip-172-31-47-193 web[3039]: TRACE_ONE_SHOT:  >>ACTION      OSS__Venetoclax__CLL                      -  ~~action30_cds2m
Feb 23 11:55:33 ip-172-31-47-193 web[3039]: TRACE_ONE_SHOT:  <<ACTION      OSS__Venetoclax__CLL                      -  ~~action30_cds2m          took   377 ms (m+r=  125 +   251)
Feb 23 11:55:33 ip-172-31-47-193 web[3039]: TRACE_ONE_SHOT: DONE           OSS__Venetoclax__CLL                      -  duration= 5695 ms
Feb 23 11:55:33 ip-172-31-47-193 web[3039]: TRACE: ContextPoolPool: [http-nio-9999-exec-5     ] done                     : idle/busy=  2/  0:   13 gets (  13 immediates    0 waits        0 ms totalWait,        0 ms max-wait)
Feb 23 11:55:33 ip-172-31-47-193 web[3039]: === [dt=    5787 ms | free=  53 MB | tot= 114 MB | max= 798 MB]: /Venetoclax/1.0/CLL
Feb 23 11:55:34 ip-172-31-47-193 web[3039]: TRACE: ContextPoolPool: [http-nio-9999-exec-6     ] get                      : idle/busy=  2/  0:   14 gets (  13 immediates    0 waits        0 ms totalWait,        0 ms max-wait)
Feb 23 11:55:34 ip-172-31-47-193 web[3039]: TRACE: ContextPoolPool: [http-nio-9999-exec-6     ] waited      0 ms         : idle/busy=  1/  1:   14 gets (  14 immediates    0 waits        0 ms totalWait,        0 ms max-wait)
Feb 23 11:55:34 ip-172-31-47-193 web[3039]: TRACE_ONE_SHOT: START          OSS__Venetoclax__CLL                      -  #actions=4
Feb 23 11:55:34 ip-172-31-47-193 web[3039]: TRACE_ONE_SHOT:  CACHE-SKIP    OSS__Venetoclax__CLL                      -  ~~action00_makeBaseModels
Feb 23 11:55:34 ip-172-31-47-193 web[3039]: TRACE_ONE_SHOT:  >>ACTION      OSS__Venetoclax__CLL                      -  ~~action10_jsonIn
Feb 23 11:55:34 ip-172-31-47-193 web[3039]: TRACE_ONE_SHOT:  <<ACTION      OSS__Venetoclax__CLL                      -  ~~action10_jsonIn         took   111 ms (m+r=   48 +    62)
Feb 23 11:55:34 ip-172-31-47-193 web[3039]: TRACE_ONE_SHOT:  >>ACTION      OSS__Venetoclax__CLL                      -  ~~action20_m2cds
Feb 23 11:55:39 ip-172-31-47-193 web[3039]: TRACE_ONE_SHOT:  <<ACTION      OSS__Venetoclax__CLL                      -  ~~action20_m2cds          took  4888 ms (m+r=   15 +  4873)
Feb 23 11:55:39 ip-172-31-47-193 web[3039]: TRACE_ONE_SHOT:  >>ACTION      OSS__Venetoclax__CLL                      -  ~~action30_cds2m
Feb 23 11:55:40 ip-172-31-47-193 web[3039]: TRACE_ONE_SHOT:  <<ACTION      OSS__Venetoclax__CLL                      -  ~~action30_cds2m          took   445 ms (m+r=  133 +   311)
Feb 23 11:55:40 ip-172-31-47-193 web[3039]: TRACE_ONE_SHOT: DONE           OSS__Venetoclax__CLL                      -  duration= 5449 ms
Feb 23 11:55:40 ip-172-31-47-193 web[3039]: TRACE: ContextPoolPool: [http-nio-9999-exec-6     ] done                     : idle/busy=  2/  0:   14 gets (  14 immediates    0 waits        0 ms totalWait,        0 ms max-wait)
Feb 23 11:55:40 ip-172-31-47-193 web[3039]: === [dt=    5537 ms | free=  20 MB | tot= 114 MB | max= 798 MB]: /Venetoclax/1.0/CLL
Feb 23 11:55:41 ip-172-31-47-193 web[3039]: TRACE: ContextPoolPool: [http-nio-9999-exec-7     ] get                      : idle/busy=  2/  0:   15 gets (  14 immediates    0 waits        0 ms totalWait,        0 ms max-wait)
Feb 23 11:55:41 ip-172-31-47-193 web[3039]: TRACE: ContextPoolPool: [http-nio-9999-exec-7     ] waited      0 ms         : idle/busy=  1/  1:   15 gets (  15 immediates    0 waits        0 ms totalWait,        0 ms max-wait)
Feb 23 11:55:41 ip-172-31-47-193 web[3039]: TRACE_ONE_SHOT: START          OSS__Venetoclax__CLL                      -  #actions=4
Feb 23 11:55:41 ip-172-31-47-193 web[3039]: TRACE_ONE_SHOT:  CACHE-SKIP    OSS__Venetoclax__CLL                      -  ~~action00_makeBaseModels
Feb 23 11:55:41 ip-172-31-47-193 web[3039]: TRACE_ONE_SHOT:  >>ACTION      OSS__Venetoclax__CLL                      -  ~~action10_jsonIn
Feb 23 11:55:41 ip-172-31-47-193 web[3039]: TRACE_ONE_SHOT:  <<ACTION      OSS__Venetoclax__CLL                      -  ~~action10_jsonIn         took   115 ms (m+r=   44 +    70)
Feb 23 11:55:41 ip-172-31-47-193 web[3039]: TRACE_ONE_SHOT:  >>ACTION      OSS__Venetoclax__CLL                      -  ~~action20_m2cds
Feb 23 11:55:46 ip-172-31-47-193 web[3039]: TRACE_ONE_SHOT:  <<ACTION      OSS__Venetoclax__CLL                      -  ~~action20_m2cds          took  4961 ms (m+r=   10 +  4950)
Feb 23 11:55:46 ip-172-31-47-193 web[3039]: TRACE_ONE_SHOT:  >>ACTION      OSS__Venetoclax__CLL                      -  ~~action30_cds2m
Feb 23 11:55:47 ip-172-31-47-193 web[3039]: TRACE_ONE_SHOT:  <<ACTION      OSS__Venetoclax__CLL                      -  ~~action30_cds2m          took   382 ms (m+r=  139 +   243)
Feb 23 11:55:47 ip-172-31-47-193 web[3039]: TRACE_ONE_SHOT: DONE           OSS__Venetoclax__CLL                      -  duration= 5461 ms
Feb 23 11:55:47 ip-172-31-47-193 web[3039]: TRACE: ContextPoolPool: [http-nio-9999-exec-7     ] done                     : idle/busy=  2/  0:   15 gets (  15 immediates    0 waits        0 ms totalWait,        0 ms max-wait)
Feb 23 11:55:47 ip-172-31-47-193 web[3039]: === [dt=    5551 ms | free=  50 MB | tot= 114 MB | max= 798 MB]: /Venetoclax/1.0/CLL
Feb 23 11:55:49 ip-172-31-47-193 web[3039]: TRACE: ContextPoolPool: [http-nio-9999-exec-8     ] get                      : idle/busy=  2/  0:   16 gets (  15 immediates    0 waits        0 ms totalWait,        0 ms max-wait)
Feb 23 11:55:49 ip-172-31-47-193 web[3039]: TRACE: ContextPoolPool: [http-nio-9999-exec-8     ] waited      0 ms         : idle/busy=  1/  1:   16 gets (  16 immediates    0 waits        0 ms totalWait,        0 ms max-wait)
Feb 23 11:55:49 ip-172-31-47-193 web[3039]: TRACE_ONE_SHOT: START          OSS__Venetoclax__CLL                      -  #actions=4
Feb 23 11:55:49 ip-172-31-47-193 web[3039]: TRACE_ONE_SHOT:  CACHE-SKIP    OSS__Venetoclax__CLL                      -  ~~action00_makeBaseModels
Feb 23 11:55:49 ip-172-31-47-193 web[3039]: TRACE_ONE_SHOT:  >>ACTION      OSS__Venetoclax__CLL                      -  ~~action10_jsonIn
Feb 23 11:55:49 ip-172-31-47-193 web[3039]: TRACE_ONE_SHOT:  <<ACTION      OSS__Venetoclax__CLL                      -  ~~action10_jsonIn         took   105 ms (m+r=   45 +    59)
Feb 23 11:55:49 ip-172-31-47-193 web[3039]: TRACE_ONE_SHOT:  >>ACTION      OSS__Venetoclax__CLL                      -  ~~action20_m2cds
Feb 23 11:55:55 ip-172-31-47-193 web[3039]: TRACE_ONE_SHOT:  <<ACTION      OSS__Venetoclax__CLL                      -  ~~action20_m2cds          took  5116 ms (m+r=   12 +  5104)
Feb 23 11:55:55 ip-172-31-47-193 web[3039]: TRACE_ONE_SHOT:  >>ACTION      OSS__Venetoclax__CLL                      -  ~~action30_cds2m
Feb 23 11:55:55 ip-172-31-47-193 web[3039]: TRACE_ONE_SHOT:  <<ACTION      OSS__Venetoclax__CLL                      -  ~~action30_cds2m          took   375 ms (m+r=  127 +   247)
Feb 23 11:55:55 ip-172-31-47-193 web[3039]: TRACE_ONE_SHOT: DONE           OSS__Venetoclax__CLL                      -  duration= 5605 ms
Feb 23 11:55:55 ip-172-31-47-193 web[3039]: TRACE: ContextPoolPool: [http-nio-9999-exec-8     ] done                     : idle/busy=  2/  0:   16 gets (  16 immediates    0 waits        0 ms totalWait,        0 ms max-wait)
Feb 23 11:55:55 ip-172-31-47-193 web[3039]: === [dt=    5683 ms | free=  23 MB | tot= 114 MB | max= 798 MB]: /Venetoclax/1.0/CLL
Feb 23 11:55:56 ip-172-31-47-193 web[3039]: TRACE: ContextPoolPool: [http-nio-9999-exec-9     ] get                      : idle/busy=  2/  0:   17 gets (  16 immediates    0 waits        0 ms totalWait,        0 ms max-wait)
Feb 23 11:55:56 ip-172-31-47-193 web[3039]: TRACE: ContextPoolPool: [http-nio-9999-exec-9     ] waited      0 ms         : idle/busy=  1/  1:   17 gets (  17 immediates    0 waits        0 ms totalWait,        0 ms max-wait)
Feb 23 11:55:56 ip-172-31-47-193 web[3039]: TRACE_ONE_SHOT: START          OSS__Venetoclax__CLL                      -  #actions=4
Feb 23 11:55:56 ip-172-31-47-193 web[3039]: TRACE_ONE_SHOT:  CACHE-SKIP    OSS__Venetoclax__CLL                      -  ~~action00_makeBaseModels
Feb 23 11:55:56 ip-172-31-47-193 web[3039]: TRACE_ONE_SHOT:  >>ACTION      OSS__Venetoclax__CLL                      -  ~~action10_jsonIn
Feb 23 11:55:57 ip-172-31-47-193 web[3039]: TRACE_ONE_SHOT:  <<ACTION      OSS__Venetoclax__CLL                      -  ~~action10_jsonIn         took   109 ms (m+r=   45 +    63)
Feb 23 11:55:57 ip-172-31-47-193 web[3039]: TRACE_ONE_SHOT:  >>ACTION      OSS__Venetoclax__CLL                      -  ~~action20_m2cds
Feb 23 11:56:01 ip-172-31-47-193 web[3039]: TRACE_ONE_SHOT:  <<ACTION      OSS__Venetoclax__CLL                      -  ~~action20_m2cds          took  4939 ms (m+r=   11 +  4928)
Feb 23 11:56:01 ip-172-31-47-193 web[3039]: TRACE_ONE_SHOT:  >>ACTION      OSS__Venetoclax__CLL                      -  ~~action30_cds2m
Feb 23 11:56:02 ip-172-31-47-193 web[3039]: TRACE_ONE_SHOT:  <<ACTION      OSS__Venetoclax__CLL                      -  ~~action30_cds2m          took   376 ms (m+r=  118 +   258)
Feb 23 11:56:02 ip-172-31-47-193 web[3039]: TRACE_ONE_SHOT: DONE           OSS__Venetoclax__CLL                      -  duration= 5427 ms
Feb 23 11:56:02 ip-172-31-47-193 web[3039]: TRACE: ContextPoolPool: [http-nio-9999-exec-9     ] done                     : idle/busy=  2/  0:   17 gets (  17 immediates    0 waits        0 ms totalWait,        0 ms max-wait)
Feb 23 11:56:02 ip-172-31-47-193 web[3039]: === [dt=    5512 ms | free=  37 MB | tot= 114 MB | max= 798 MB]: /Venetoclax/1.0/CLL
^C
[root@ip-172-31-47-193 ~]#

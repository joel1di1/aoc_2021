# frozen_string_literal: true

require 'colorize'
require 'readline'
require 'byebug'
require 'set'
require_relative '../../fwk'


class Workflow
  attr_reader :name, :rules, :default

  def initialize(str)
    @name = str[/^([a-z]+)/].to_sym
    rules_str = str.scan(/{(.*)}/)[0][0]
    rules_str, @default = rules_str.scan(/(.*),(\w+)$/)[0]
    @default = @default.to_sym
    rules_strs = rules_str.split(',')
    @rules = rules_strs.map do |rule_str|
      var, op, value, dest = rule_str.scan(/([a-z]+)([<>])(\d+):(\w+)/)[0]
      [var.to_sym, op, value.to_i, dest.to_sym]
    end
  end

  def process(part)
    rules.each do |var, op, value, dest|
      return dest if part[var].send(op, value)
    end
    default
  end
end

parts = [
{x: 637,m: 679,a: 312,s: 22},
{x: 48,m: 1047,a: 228,s: 744},
{x: 3643,m: 1704,a: 1029,s: 1169},
{x: 53,m: 1228,a: 2175,s: 653},
{x: 1424,m: 1872,a: 193,s: 706},
{x: 347,m: 2373,a: 453,s: 9},
{x: 1235,m: 56,a: 149,s: 971},
{x: 296,m: 433,a: 693,s: 37},
{x: 866,m: 612,a: 439,s: 168},
{x: 1473,m: 2481,a: 293,s: 837},
{x: 70,m: 1712,a: 705,s: 1482},
{x: 680,m: 262,a: 3438,s: 1628},
{x: 866,m: 1085,a: 276,s: 812},
{x: 349,m: 1359,a: 353,s: 1425},
{x: 78,m: 2976,a: 283,s: 89},
{x: 616,m: 174,a: 448,s: 1260},
{x: 663,m: 859,a: 21,s: 1652},
{x: 821,m: 2075,a: 1837,s: 172},
{x: 1557,m: 1003,a: 3035,s: 597},
{x: 1001,m: 2006,a: 21,s: 2646},
{x: 2165,m: 433,a: 850,s: 1261},
{x: 2554,m: 2904,a: 2220,s: 44},
{x: 170,m: 173,a: 315,s: 847},
{x: 25,m: 1416,a: 1000,s: 1056},
{x: 488,m: 1742,a: 1363,s: 600},
{x: 254,m: 1506,a: 23,s: 2837},
{x: 286,m: 267,a: 861,s: 1183},
{x: 32,m: 1317,a: 458,s: 851},
{x: 1859,m: 750,a: 987,s: 1257},
{x: 1386,m: 588,a: 143,s: 1439},
{x: 540,m: 1047,a: 470,s: 44},
{x: 1458,m: 1859,a: 2116,s: 973},
{x: 435,m: 297,a: 3008,s: 791},
{x: 1275,m: 84,a: 259,s: 605},
{x: 128,m: 607,a: 309,s: 462},
{x: 357,m: 2506,a: 2124,s: 1844},
{x: 128,m: 215,a: 247,s: 7},
{x: 3130,m: 2544,a: 605,s: 1577},
{x: 562,m: 3681,a: 2009,s: 546},
{x: 986,m: 1191,a: 1572,s: 197},
{x: 133,m: 6,a: 1660,s: 751},
{x: 359,m: 153,a: 291,s: 2259},
{x: 423,m: 83,a: 315,s: 633},
{x: 647,m: 95,a: 47,s: 2840},
{x: 2233,m: 346,a: 1284,s: 2448},
{x: 319,m: 3302,a: 1638,s: 16},
{x: 2874,m: 520,a: 322,s: 595},
{x: 560,m: 10,a: 1705,s: 2771},
{x: 1553,m: 2551,a: 1402,s: 3532},
{x: 254,m: 210,a: 122,s: 759},
{x: 3214,m: 183,a: 1767,s: 2712},
{x: 1297,m: 704,a: 995,s: 387},
{x: 165,m: 794,a: 1588,s: 3378},
{x: 15,m: 1006,a: 1211,s: 1987},
{x: 627,m: 381,a: 3207,s: 2822},
{x: 1506,m: 8,a: 656,s: 649},
{x: 49,m: 138,a: 455,s: 247},
{x: 1024,m: 224,a: 1316,s: 528},
{x: 56,m: 115,a: 1077,s: 248},
{x: 30,m: 1802,a: 55,s: 553},
{x: 1722,m: 127,a: 2903,s: 370},
{x: 1218,m: 2366,a: 1710,s: 1513},
{x: 1146,m: 3065,a: 973,s: 1740},
{x: 263,m: 1997,a: 2035,s: 3459},
{x: 974,m: 1322,a: 40,s: 42},
{x: 998,m: 136,a: 9,s: 3001},
{x: 1826,m: 2737,a: 230,s: 1259},
{x: 67,m: 334,a: 270,s: 61},
{x: 603,m: 535,a: 507,s: 3315},
{x: 131,m: 1009,a: 234,s: 1575},
{x: 263,m: 1587,a: 1830,s: 99},
{x: 2090,m: 1638,a: 489,s: 2219},
{x: 870,m: 275,a: 504,s: 3082},
{x: 1052,m: 19,a: 1116,s: 2059},
{x: 814,m: 77,a: 2578,s: 1010},
{x: 131,m: 3,a: 2878,s: 2398},
{x: 699,m: 2124,a: 420,s: 576},
{x: 902,m: 932,a: 3906,s: 1246},
{x: 343,m: 215,a: 262,s: 51},
{x: 967,m: 1205,a: 210,s: 181},
{x: 2547,m: 413,a: 602,s: 667},
{x: 477,m: 41,a: 306,s: 255},
{x: 218,m: 757,a: 197,s: 1051},
{x: 369,m: 702,a: 1123,s: 1482},
{x: 2706,m: 1331,a: 520,s: 1210},
{x: 917,m: 743,a: 1941,s: 1847},
{x: 217,m: 2342,a: 388,s: 974},
{x: 450,m: 439,a: 1254,s: 318},
{x: 2475,m: 1480,a: 1809,s: 2789},
{x: 2414,m: 1388,a: 227,s: 926},
{x: 1390,m: 3189,a: 581,s: 1240},
{x: 14,m: 1797,a: 40,s: 512},
{x: 553,m: 373,a: 896,s: 1240},
{x: 1585,m: 111,a: 604,s: 416},
{x: 974,m: 1014,a: 969,s: 157},
{x: 2710,m: 655,a: 2667,s: 1779},
{x: 328,m: 2415,a: 828,s: 312},
{x: 3747,m: 366,a: 368,s: 579},
{x: 835,m: 463,a: 794,s: 2219},
{x: 187,m: 986,a: 812,s: 400},
{x: 1988,m: 98,a: 423,s: 15},
{x: 1353,m: 2340,a: 465,s: 2676},
{x: 1757,m: 3396,a: 389,s: 1415},
{x: 33,m: 78,a: 1429,s: 15},
{x: 2994,m: 595,a: 142,s: 1224},
{x: 523,m: 273,a: 94,s: 574},
{x: 3061,m: 214,a: 28,s: 1265},
{x: 844,m: 1053,a: 2558,s: 469},
{x: 60,m: 197,a: 189,s: 21},
{x: 174,m: 2924,a: 94,s: 1004},
{x: 591,m: 277,a: 402,s: 38},
{x: 3317,m: 651,a: 438,s: 252},
{x: 1412,m: 631,a: 611,s: 776},
{x: 287,m: 768,a: 58,s: 464},
{x: 3522,m: 149,a: 14,s: 432},
{x: 240,m: 1505,a: 1076,s: 1624},
{x: 390,m: 112,a: 1212,s: 180},
{x: 109,m: 1406,a: 263,s: 2793},
{x: 1276,m: 991,a: 762,s: 998},
{x: 297,m: 489,a: 50,s: 1450},
{x: 1007,m: 1658,a: 2814,s: 1308},
{x: 473,m: 1415,a: 2684,s: 106},
{x: 250,m: 1795,a: 410,s: 593},
{x: 1303,m: 1588,a: 157,s: 442},
{x: 838,m: 312,a: 515,s: 1488},
{x: 2121,m: 2257,a: 2331,s: 496},
{x: 555,m: 2223,a: 2326,s: 272},
{x: 200,m: 9,a: 14,s: 2016},
{x: 3255,m: 176,a: 120,s: 2796},
{x: 1599,m: 1313,a: 2679,s: 3245},
{x: 435,m: 542,a: 738,s: 2288},
{x: 533,m: 284,a: 1358,s: 442},
{x: 470,m: 2071,a: 133,s: 2502},
{x: 2600,m: 2063,a: 332,s: 494},
{x: 143,m: 264,a: 1001,s: 161},
{x: 1148,m: 206,a: 921,s: 237},
{x: 1611,m: 626,a: 476,s: 319},
{x: 1060,m: 814,a: 2173,s: 158},
{x: 1848,m: 494,a: 1279,s: 1555},
{x: 632,m: 572,a: 295,s: 2047},
{x: 1119,m: 1454,a: 1058,s: 86},
{x: 2193,m: 544,a: 2138,s: 906},
{x: 874,m: 1325,a: 1439,s: 1961},
{x: 1925,m: 2476,a: 850,s: 1701},
{x: 1104,m: 2098,a: 5,s: 1434},
{x: 918,m: 3299,a: 292,s: 3522},
{x: 1633,m: 1140,a: 2744,s: 37},
{x: 755,m: 288,a: 670,s: 621},
{x: 89,m: 1084,a: 81,s: 722},
{x: 3165,m: 950,a: 461,s: 716},
{x: 555,m: 2675,a: 2652,s: 356},
{x: 1427,m: 38,a: 935,s: 1},
{x: 1298,m: 604,a: 1940,s: 562},
{x: 1560,m: 1313,a: 25,s: 2665},
{x: 1576,m: 1882,a: 897,s: 136},
{x: 776,m: 1456,a: 130,s: 1934},
{x: 76,m: 26,a: 441,s: 1171},
{x: 530,m: 1294,a: 115,s: 79},
{x: 1613,m: 1263,a: 78,s: 1949},
{x: 27,m: 1011,a: 1026,s: 673},
{x: 2703,m: 1438,a: 1356,s: 3536},
{x: 132,m: 526,a: 367,s: 2659},
{x: 2650,m: 719,a: 1185,s: 1158},
{x: 1048,m: 390,a: 1985,s: 2896},
{x: 411,m: 235,a: 1177,s: 592},
{x: 518,m: 3120,a: 1005,s: 1362},
{x: 80,m: 63,a: 216,s: 1783},
{x: 671,m: 101,a: 164,s: 2676},
{x: 1104,m: 401,a: 2830,s: 117},
{x: 1102,m: 265,a: 886,s: 285},
{x: 317,m: 489,a: 166,s: 781},
{x: 902,m: 996,a: 1611,s: 879},
{x: 1820,m: 1245,a: 1181,s: 673},
{x: 144,m: 2642,a: 40,s: 2092},
{x: 1297,m: 1641,a: 196,s: 3085},
{x: 269,m: 127,a: 460,s: 211},
{x: 2,m: 821,a: 1267,s: 55},
{x: 159,m: 534,a: 2143,s: 97},
{x: 1281,m: 166,a: 496,s: 227},
{x: 1407,m: 768,a: 59,s: 2109},
{x: 2013,m: 41,a: 528,s: 515},
{x: 648,m: 1004,a: 472,s: 1039},
{x: 3644,m: 3335,a: 1785,s: 185},
{x: 2532,m: 966,a: 614,s: 377},
{x: 1579,m: 291,a: 1835,s: 37},
{x: 1027,m: 234,a: 544,s: 1028},
{x: 763,m: 231,a: 661,s: 49},
{x: 1281,m: 388,a: 103,s: 340},
{x: 148,m: 595,a: 439,s: 483},
{x: 3322,m: 246,a: 272,s: 442},
{x: 672,m: 935,a: 536,s: 366},
{x: 51,m: 2137,a: 1026,s: 1307},
{x: 2049,m: 1351,a: 331,s: 1107},
{x: 654,m: 2120,a: 45,s: 3656},
{x: 2912,m: 165,a: 1577,s: 128},
{x: 388,m: 43,a: 837,s: 281},
{x: 373,m: 1362,a: 33,s: 949},
{x: 556,m: 747,a: 45,s: 769},
{x: 72,m: 1008,a: 327,s: 77},
{x: 2739,m: 143,a: 89,s: 48},
]

workflows = File.readlines("#{__dir__}/input19_w.txt", chomp: true).map { |str| Workflow.new(str) }

workflows_by_name = workflows.map { |workflow| [workflow.name, workflow] }.to_h

accepted_parts = parts.select do |part|
  current_workflow = workflows_by_name[:in]
  next_w = current_workflow.process(part)

  until [:A, :R].include?(next_w)
    current_workflow = workflows_by_name[next_w]
    next_w = current_workflow.process(part)
  end

  next_w == :A
end

sum = accepted_parts.map do |part|
  part[:x] + part[:m] + part[:a] + part[:s]
end.sum

puts "Part 1: #{sum}"
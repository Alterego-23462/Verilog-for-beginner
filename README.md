# Verilog-for-beginner
Verilog零基础入门，北交李金城老师的B站网课verilog实验的代码复现。网课视频链接：https://www.bilibili.com/video/BV1hX4y137Ph?spm_id_from=333.788.videopod.episodes&amp;vd_source=11ff0a5b820cb370b3c2cede16af1f15&amp;p=10。

第10讲
串口指令处理器
9+6=15，所以输出结果应该是0000 1111，所以TX图像从左到右应该是：
0（起始位） 1111 0000 1（结束位）.
而RX_send为1 0000 1001 0
1 0000 0110 0
1 0000 1010 0
1111 1111 1111 1111，
所以图像从左到右应该是上述反过来：1111 1111 1111 0 0101 0000 1...


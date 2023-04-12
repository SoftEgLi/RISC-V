# Arch-2023Spring-Fudan

> 2022年春 计算机组成与体系结构荣誉课 课程代码仓库。

课程Wiki：https://gitlab.com/fudan-systa/arch-2023spring-fudan/-/wikis/home

Arch-2022Sping-FDU  
│── build：仿真测试时才会生成的目录  
│── difftest：仿真测试框架  
│── ready-to-run：仿真测试文件目录（包括汇编文件和二进制文件等）   
│── verilate：verilator部分仿真文件目录    
│── vivado  
│　　└── test1  
│　　　　　└── project：vivado项目工程目录  
│── vsrc：需要写的CPU代码所在目录  
│　　├── include：头文件目录  
│　　├── pipeline  
│　　　　　├── regfile：寄存器文件目录，寄存器组模块已给出  
│　　　　　├── execute：流水线执行阶段目录，alu模块已给出  
│　　　　　└── core.sv：五级流水线主体代码  
│　　├── ram：内存控制相关目录  
│　　├── util：访存接口相关目录  
│　　├── add_sources.tcl  
│　　├── mycpu_top_nodelay.sv：以下是项目头文件  
│　　├── mycpu_top.sv  
│　　├── SimTop.sv  
│　　└── VTop.sv  
│── xpm_memory：Xilinx的内存IP  
│── Makefile：仿真测试的命令汇总  
│── README.md: 此文件  

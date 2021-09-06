# 基础

```go
// 声明包
package main
// 导入语句
import "fmt"
// 函数外只能放置标识符(变量、常量、类型、函数)
// 程序入口
func main() {
	fmt.Println("Hello world!")
}

```

# 变量

```go
package main
import "fmt"
// 批量声明
// 变量必须声明才能使用
var (
	name string
	age  int
	isOk bool
)
func main() {
	name = "lixiang"
	age = 16
	isOk = true
	// 变量必须被使用
	fmt.Printf("name:%s\n", name) //占位
	fmt.Println(age)              // 换行
	fmt.Print(isOk)
	// 声明变量同时赋值
	var s1 string = "whb"
	fmt.Print(s1)
	// 类型推导（根据值判断变量类型）
	var s2 = 20
	fmt.Println(s2)
	// 简短变量声明,只能在函数里用，函数外无法使用
	s3 := "哈哈哈"
	fmt.Print(s3)
}

```

# 常量

```go
package main
import "fmt"
//常量
//在程序运行期间是不会改变的
const pi = 3.1415926

//批量声明
const (
	statusOk = 200
	notFount = 404
)
//批量声明时，如何某一行声明后没有赋值，默认和上一行一致
const (
	n1 = 100
	n2
	n3
)
// iota
const (
	a1 = iota //0
	a2        //1
	a3        //2
)
// 使用_跳过某值
const (
	b1 = iota //0
	b2        //1
	_         //2
	b3        //3
)
// 插队
const (
	c1 = iota //0
	c2 = 100  //100
	c3        //100
	c4 = iota //3
)
// 多个常量声明在一行
const (
	d1, d2 = iota + 1, iota + 2 // d1=1 d2=2
	d3, d4 = iota + 1, iota + 2 // d3=2 d4=3
)
// 定义数量级
const (
	_  = iota
	KB = 1 << (10 * iota)
	MB = 1 << (10 * iota)
	GB = 1 << (10 * iota)
	TB = 1 << (10 * iota)
)
func main() {
	fmt.Println("KB:", KB)
	fmt.Println("MB:", MB)
	fmt.Println("GB:", GB)
	fmt.Println("TB:", TB)
}
```

# int(整型)

```go
package main
import "fmt"
// 整型
func main() {
	// 把十进制转换为2进制、8进制和16进制
	var i1 = 101
	fmt.Printf("%d\n", i1)
	fmt.Printf("%b\n", i1)
	fmt.Printf("%o\n", i1)
	fmt.Printf("%x\n", i1)
	// 八进制转10进制
	var i2 = 077
	fmt.Printf("%d\n", i2)
	// 十六进制转10进制
	i3 := 0x1234567
	fmt.Printf("%d\n", i3)
	// 查看变量类型
	fmt.Printf("%T\n", i3)
	// 声明int8类型变量
	i4 := int8(9)
	fmt.Printf("%T\n", i4)
}
```

# float(浮点数)

```go
package main
import (
	"fmt"
)
// 浮点数
func main() {
	//math.MaxFloat32 //浮点数
	f1 := 1.23456
	fmt.Printf("%T\n", f1) // 默认浮点型为float64
	f2 := float32(1.23456)
	fmt.Printf("%T\n", f2) // 显示声明float32类型
}
```

# bool(布尔值)

```go
package main
import "fmt"
func main() {
	b1 := true
	var b2 bool //默认是flase
	fmt.Printf("%T\n", b1)
	fmt.Printf("%T vlaue:%v\n", b2, b2)
}
```

# fmt占位符

```go
package main
import "fmt"
// fmt占位符
func main() {
	var n = 100
	fmt.Printf("%T\n", n) // 查看类型
	fmt.Printf("%c\n", n) // 输出单个字符
	fmt.Printf("%v\n", n) // 查看变量值
	fmt.Printf("%b\n", n) // 二进制
	fmt.Printf("%d\n", n) //十进制
	fmt.Printf("%o\n", n) //八进制
	fmt.Printf("%x\n", n) //十六进制
	var s = "hello"
	fmt.Printf("%s\n", s) //字符串
	fmt.Printf("%v\n", s)

}
```

# string(字符串)

```go
package main
import (
	"fmt"
	"strings"
)
// 字符串
func main() {
	// \ 本来具有特殊含义需要再加\将其转义
	path := "\"E:\\go\\src\\github.com\\zphyzp\\day01\"\n"
	fmt.Printf(path)
	s := "i'm ok"
	fmt.Println(s)
	// 换行输出、原样输出
	s2 := `
		鹅鹅鹅
	曲项向天歌
		白毛浮绿水
	红掌拨清波
	`
	fmt.Println(s2)
	s3 := `E:\go\src\github.com\zphyzp\day01\`
	fmt.Println(s3)
	// 字符串长度
	fmt.Println(len(s3))
	// 字符串拼接
	name := "理想"
	world := "dsb"
	ss := name + world
	fmt.Println(ss)
	ss1 := fmt.Sprintf("%s%s", name, world)
	fmt.Println(ss1)
	// 分割
	ret := strings.Split(s3, "\\")
	fmt.Println(ret)
	// 包含
	fmt.Println(strings.Contains(ss, "理想"))
	// 判断前缀
	fmt.Println(strings.HasPrefix(ss, "理想"))
	// 判断后缀
	fmt.Println(strings.HasSuffix(ss, "理想"))
	//字符串中字符位置
	s4 := "abcdeb"
	fmt.Println(strings.Index(s4, "c"))
	fmt.Println(strings.LastIndex(s4, "b"))
	//连接
	fmt.Println(strings.Join(ret, "+"))
}
```

# 类型转换

```go
package main
import "fmt"
func main() {
	// 字符串修改
	s2 := "白萝卜"
	s3 := []rune(s2)        //把字符串强制转换成一个rune切片
	s3[0] = '红'             // 替换字符串，所以用单引号包裹
	fmt.Println(string(s3)) //把rune切片强制转换为字符串
	// 类型转换
	var n1 = 10
	var f float32
	f = float32(n1) // 强制转换为浮点类型float32
	fmt.Println(f)
	fmt.Printf("%T\n", f)
}
```

# if

```go
package main
import "fmt"
// if判断
func main() {
	age := 19
	if age > 18 {
		fmt.Println("成人了")
	} else {
		fmt.Println("回家写作业去")
	}
	// 多个条件
	if age > 35 {
		fmt.Println("人到中年")
	} else if age > 18 {
		fmt.Println("青年")
	} else {
		fmt.Println("好好学习")
	}
	// 作用域
	// 此时age只在if{}作用域内生效，判断完成后age变量失效，可以减少内存占用。
	if age := 19; age > 18 {
		fmt.Println("成人了")
	} else {
		fmt.Println("回家写作业去")
	}
}
```

# for

```go
package main

import "fmt"
// for循环
func main() {
	// 基本语句
	for i := 0; i < 5; i++ {
		fmt.Println(i)
	}
	fmt.Println("#####################")
	// 变种1
	var a = 5
	for ; a < 10; a++ {
		fmt.Println(a)
	}
	fmt.Println("#####################")
	// 变种2
	var b = 5
	for b < 10 {
		fmt.Println(b)
		b++
	}
	fmt.Println("#####################")
	// for range 循环
	s := "hello 通州"
	for i, v := range s {
		fmt.Printf("%d %c\n", i, v)
	}
}
```


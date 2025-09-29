package main

import (
	"os"
	"strconv"
)

func CreateDirecotry() {
	dir := "../InitRun/"
	if _, err := os.Stat(dir); os.IsNotExist(err) {
		err := os.Mkdir(dir, 0755)
		if err != nil {
			panic(err)
		}
	}
}

func InitInterleavings(opt_name string, r_id int) {
	file, err := os.OpenFile("../InitRun/events.facts", os.O_APPEND|os.O_CREATE|os.O_WRONLY, 0644)
	if err != nil {
		panic(err)
	}
	defer file.Close()

	_, err = file.WriteString(opt_name + "_" + strconv.Itoa(r_id) + "\n")
	if err != nil {
		panic(err)
	}
}

func (c *Counter) setValueWrap(v int, opt_name string) {
	//fmt.Println("Before setValue:", v)
	c.SetVal(v, opt_name)
	CreateDirecotry()
	InitInterleavings(opt_name, c.id)
}

func (c *Counter) toMarshalWrap() []byte {
	CreateDirecotry()
	InitInterleavings("Broadcast", c.id)
	return c.ToMarshal()
}

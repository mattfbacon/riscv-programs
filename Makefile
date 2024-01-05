.SECONDARY:
.SUFFIXES:

BUILD_DIR := build

$(BUILD_DIR)/%.riscv: $(BUILD_DIR)/%.riscv.o $(BUILD_DIR)/%.riscv.lst
	riscv64-linux-gnu-gcc -g -static $< -o $@

$(BUILD_DIR)/%.riscv.o $(BUILD_DIR)/%.riscv.lst &: %.riscv.s
	mkdir -p $(BUILD_DIR)
	riscv64-linux-gnu-as -alh -g $< -o $(patsubst %.s,$(BUILD_DIR)/%.o,$<) > $(patsubst %.s,$(BUILD_DIR)/%.lst,$<)

$(BUILD_DIR)/%.armv7: $(BUILD_DIR)/%.armv7.o $(BUILD_DIR)/%.armv7.lst
	arm-linux-gnueabihf-gcc -g -static $< -o $@

$(BUILD_DIR)/%.armv7.o $(BUILD_DIR)/%.armv7.lst &: %.armv7.s
	mkdir -p $(BUILD_DIR)
	arm-linux-gnueabihf-as -alh -g $< -o $(patsubst %.s,$(BUILD_DIR)/%.o,$<) > $(patsubst %.s,$(BUILD_DIR)/%.lst,$<)

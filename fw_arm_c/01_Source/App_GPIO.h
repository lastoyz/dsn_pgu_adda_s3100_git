#ifndef	_APP_GPIO_H
#define	_APP_GPIO_H

#include 	"top_core_info.h"

#define GPIO_LED_CNT	2
#define GPIO_SWITCH_CNT	6

typedef	struct{
	ioStatus_t	io[GPIO_LED_CNT];
}gpioLED_t;

typedef	struct{
	ioStatus_t	io[GPIO_SWITCH_CNT];
}gpioSwitch_t;

enum{
	LED_GREEN = 0,
	LED_YELLOW,
	LED_RED
}gpio_led_color_t;

enum{
	LED_ON = 0,
	LED_OFF
}gpio_led_state_t;

enum{
	NAND_WP_LOW = 0,
	NAND_WP_HIGH
}gpio_nand_wp_state_t;

extern	bitCtrl8_t		switchFlag;

extern	u8	swData;

extern	u8	ledDisable;


#ifdef __cplusplus
extern "C" {
#endif

void GPIO_LedInit();
void GPIO_LedCtrl(u8 position, u8 status);
void GPIO_LedToggle(u8 position);
void GPIO_LedRun();
void GPIO_LedClear();

void GPIO_EXTI_Init();

void GPIO_NandWpInit();
void GPIO_NandWpCtrl(u8 status);


#ifdef __cplusplus
}
#endif

#endif	// _APP_GPIO_H

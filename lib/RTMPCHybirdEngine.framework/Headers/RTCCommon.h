#ifndef __RTC_COMMON_H__
#define __RTC_COMMON_H__

typedef enum AnyRTCErrorCode {
    AnyRTC_OK = 0,				// ����
    AnyRTC_UNKNOW = 1,			// δ֪����
    AnyRTC_EXCEPTION = 2,		// SDK�����쳣
    AnyRTC_NET_ERR = 100,		// �������
    AnyRTC_LIVE_ERR = 101,		// ֱ������
    AnyRTC_BAD_REQ = 201,		// ����֧�ֵĴ�������
    AnyRTC_AUTH_FAIL = 202,		// ��֤ʧ��
    AnyRTC_NO_USER = 203,		// �˿�������Ϣ������
    AnyRTC_SQL_ERR = 204,		// �������ڲ����ݿ����
    AnyRTC_ARREARS = 205,		// �˺�Ƿ��
    AnyRTC_LOCKED = 206,		// �˺ű�����
    AnyRTC_FORCE_EXIT = 207		// ǿ���뿪
}AnyRTCErrorCode;

typedef enum RTCVideoLayout
{
    RTC_V_1X3 = 0 ,       // Default - One big screen and 3 subscreens
    RTC_V_3X3_auto,       // All screens as same size & auto layout
}RTCVideoLayout;

typedef enum RTCScreenOrientation{
    RTC_SCRN_Portrait = 0,
    RTC_SCRN_LandscapeRight,
    RTC_SCRN_PortraitUpsideDown,
    RTC_SCRN_LandscapeLeft,
    RTC_SCRN_Auto
}RTCScreenOrientation;

#endif	// __RTC_COMMON_H__

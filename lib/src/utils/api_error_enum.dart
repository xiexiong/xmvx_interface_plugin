// ignore_for_file: constant_identifier_names

enum ApiErrorCode {
  // 请求成功
  SUCCESS(10000, "请求成功"),
  // 参数错误相关
  ECReqInvalidArgs(50200, "参数错误,检查入参及MIME类型"),
  ECReqMissingArgs(50201, "缺少参数,检查入参及MIME类型"),
  ECParseArgs(50204, "参数类型错误/参数缺失,检查入参及MIME类型"),
  // 图像错误相关
  ECImageSizeLimited(50205, "图像尺寸超过限制,参考接口文档入参要求部分"),
  ECImageEmpty(50206, "请求参数中没有获取到图像,检查入参"),
  ECImageDecodeError(
    50207,
    "图像解码错误：没有获取到图像或者通过image_base64参数传递图像是base64解码错误,检查输出图片或检查base64是否错误携带前缀",
  ),
  // 视频错误相关
  ECVideoEmpty(50209, "请求参数中没有获取到视频,检查入参"),
  ECVideoDecodeError(50210, "视频解码错误,检查输入视频是否不正确"),
  ECVideoSizeLimited(50211, "视频尺寸超过限制,检查输入视频大小"),
  ECVideoTimeTooLong(50214, "输入视频时长过大,检查输入视频时长"),
  // 请求体错误
  ECReqBodySizeLimited(50213, "请求Body过大，超出接口限制,检查请求Body大小"),
  // 处理失败
  ECRPCProcess(50215, "由于输入的图片、视频、参数等不满足要求，导致请求处理失败"),
  // 算法服务错误
  ECJPFaceDetect(60102, "算法服务需要输入人脸，但未检测到"),
  // 内容审核错误
  ECFSLeaderRiskError(60208, "输入图片中包含敏感信息，未通过审核"),
  // 权限错误
  ECAuth(50400, "权限校验失败"),
  ECReqMethod(50402, "访问的接口不存在,检查入参"),
  ECReqLimit(50429, "超过调用QPS限制,购买QPS增项包"),
  ECInternal(50500, "服务器内部错误,提工单"),
  ECRPCInternal(50501, "服务器内部RPC错误,提工单"),
  // 未知错误
  UNKNOWN_ERROR(-1, "未知错误");

  final int code;
  final String message;

  const ApiErrorCode(this.code, this.message);

  static ApiErrorCode fromCode(int code) {
    for (var errorCode in ApiErrorCode.values) {
      if (errorCode.code == code) {
        return errorCode;
      }
    }
    return UNKNOWN_ERROR;
  }
}

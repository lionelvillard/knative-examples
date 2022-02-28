// Code generated by protoc-gen-go. DO NOT EDIT.
// versions:
// 	protoc-gen-go v1.25.0
// 	protoc        v3.14.0
// source: math.proto

package protobuf

import (
	context "context"
	proto "github.com/golang/protobuf/proto"
	grpc "google.golang.org/grpc"
	codes "google.golang.org/grpc/codes"
	status "google.golang.org/grpc/status"
	protoreflect "google.golang.org/protobuf/reflect/protoreflect"
	protoimpl "google.golang.org/protobuf/runtime/protoimpl"
	reflect "reflect"
	sync "sync"
)

const (
	// Verify that this generated code is sufficiently up-to-date.
	_ = protoimpl.EnforceVersion(20 - protoimpl.MinVersion)
	// Verify that runtime/protoimpl is sufficiently up-to-date.
	_ = protoimpl.EnforceVersion(protoimpl.MaxVersion - 20)
)

// This is a compile-time assertion that a sufficiently up-to-date version
// of the legacy proto package is being used.
const _ = proto.ProtoPackageIsVersion4

type Request struct {
	state         protoimpl.MessageState
	sizeCache     protoimpl.SizeCache
	unknownFields protoimpl.UnknownFields

	Num int32 `protobuf:"varint,1,opt,name=num,proto3" json:"num,omitempty"`
}

func (x *Request) Reset() {
	*x = Request{}
	if protoimpl.UnsafeEnabled {
		mi := &file_math_proto_msgTypes[0]
		ms := protoimpl.X.MessageStateOf(protoimpl.Pointer(x))
		ms.StoreMessageInfo(mi)
	}
}

func (x *Request) String() string {
	return protoimpl.X.MessageStringOf(x)
}

func (*Request) ProtoMessage() {}

func (x *Request) ProtoReflect() protoreflect.Message {
	mi := &file_math_proto_msgTypes[0]
	if protoimpl.UnsafeEnabled && x != nil {
		ms := protoimpl.X.MessageStateOf(protoimpl.Pointer(x))
		if ms.LoadMessageInfo() == nil {
			ms.StoreMessageInfo(mi)
		}
		return ms
	}
	return mi.MessageOf(x)
}

// Deprecated: Use Request.ProtoReflect.Descriptor instead.
func (*Request) Descriptor() ([]byte, []int) {
	return file_math_proto_rawDescGZIP(), []int{0}
}

func (x *Request) GetNum() int32 {
	if x != nil {
		return x.Num
	}
	return 0
}

type Response struct {
	state         protoimpl.MessageState
	sizeCache     protoimpl.SizeCache
	unknownFields protoimpl.UnknownFields

	Result int32 `protobuf:"varint,1,opt,name=result,proto3" json:"result,omitempty"`
}

func (x *Response) Reset() {
	*x = Response{}
	if protoimpl.UnsafeEnabled {
		mi := &file_math_proto_msgTypes[1]
		ms := protoimpl.X.MessageStateOf(protoimpl.Pointer(x))
		ms.StoreMessageInfo(mi)
	}
}

func (x *Response) String() string {
	return protoimpl.X.MessageStringOf(x)
}

func (*Response) ProtoMessage() {}

func (x *Response) ProtoReflect() protoreflect.Message {
	mi := &file_math_proto_msgTypes[1]
	if protoimpl.UnsafeEnabled && x != nil {
		ms := protoimpl.X.MessageStateOf(protoimpl.Pointer(x))
		if ms.LoadMessageInfo() == nil {
			ms.StoreMessageInfo(mi)
		}
		return ms
	}
	return mi.MessageOf(x)
}

// Deprecated: Use Response.ProtoReflect.Descriptor instead.
func (*Response) Descriptor() ([]byte, []int) {
	return file_math_proto_rawDescGZIP(), []int{1}
}

func (x *Response) GetResult() int32 {
	if x != nil {
		return x.Result
	}
	return 0
}

var File_math_proto protoreflect.FileDescriptor

var file_math_proto_rawDesc = []byte{
	0x0a, 0x0a, 0x6d, 0x61, 0x74, 0x68, 0x2e, 0x70, 0x72, 0x6f, 0x74, 0x6f, 0x12, 0x08, 0x70, 0x72,
	0x6f, 0x74, 0x6f, 0x62, 0x75, 0x66, 0x22, 0x1b, 0x0a, 0x07, 0x52, 0x65, 0x71, 0x75, 0x65, 0x73,
	0x74, 0x12, 0x10, 0x0a, 0x03, 0x6e, 0x75, 0x6d, 0x18, 0x01, 0x20, 0x01, 0x28, 0x05, 0x52, 0x03,
	0x6e, 0x75, 0x6d, 0x22, 0x22, 0x0a, 0x08, 0x52, 0x65, 0x73, 0x70, 0x6f, 0x6e, 0x73, 0x65, 0x12,
	0x16, 0x0a, 0x06, 0x72, 0x65, 0x73, 0x75, 0x6c, 0x74, 0x18, 0x01, 0x20, 0x01, 0x28, 0x05, 0x52,
	0x06, 0x72, 0x65, 0x73, 0x75, 0x6c, 0x74, 0x32, 0x3a, 0x0a, 0x04, 0x4d, 0x61, 0x74, 0x68, 0x12,
	0x32, 0x0a, 0x03, 0x4d, 0x61, 0x78, 0x12, 0x11, 0x2e, 0x70, 0x72, 0x6f, 0x74, 0x6f, 0x62, 0x75,
	0x66, 0x2e, 0x52, 0x65, 0x71, 0x75, 0x65, 0x73, 0x74, 0x1a, 0x12, 0x2e, 0x70, 0x72, 0x6f, 0x74,
	0x6f, 0x62, 0x75, 0x66, 0x2e, 0x52, 0x65, 0x73, 0x70, 0x6f, 0x6e, 0x73, 0x65, 0x22, 0x00, 0x28,
	0x01, 0x30, 0x01, 0x62, 0x06, 0x70, 0x72, 0x6f, 0x74, 0x6f, 0x33,
}

var (
	file_math_proto_rawDescOnce sync.Once
	file_math_proto_rawDescData = file_math_proto_rawDesc
)

func file_math_proto_rawDescGZIP() []byte {
	file_math_proto_rawDescOnce.Do(func() {
		file_math_proto_rawDescData = protoimpl.X.CompressGZIP(file_math_proto_rawDescData)
	})
	return file_math_proto_rawDescData
}

var file_math_proto_msgTypes = make([]protoimpl.MessageInfo, 2)
var file_math_proto_goTypes = []interface{}{
	(*Request)(nil),  // 0: protobuf.Request
	(*Response)(nil), // 1: protobuf.Response
}
var file_math_proto_depIdxs = []int32{
	0, // 0: protobuf.Math.Max:input_type -> protobuf.Request
	1, // 1: protobuf.Math.Max:output_type -> protobuf.Response
	1, // [1:2] is the sub-list for method output_type
	0, // [0:1] is the sub-list for method input_type
	0, // [0:0] is the sub-list for extension type_name
	0, // [0:0] is the sub-list for extension extendee
	0, // [0:0] is the sub-list for field type_name
}

func init() { file_math_proto_init() }
func file_math_proto_init() {
	if File_math_proto != nil {
		return
	}
	if !protoimpl.UnsafeEnabled {
		file_math_proto_msgTypes[0].Exporter = func(v interface{}, i int) interface{} {
			switch v := v.(*Request); i {
			case 0:
				return &v.state
			case 1:
				return &v.sizeCache
			case 2:
				return &v.unknownFields
			default:
				return nil
			}
		}
		file_math_proto_msgTypes[1].Exporter = func(v interface{}, i int) interface{} {
			switch v := v.(*Response); i {
			case 0:
				return &v.state
			case 1:
				return &v.sizeCache
			case 2:
				return &v.unknownFields
			default:
				return nil
			}
		}
	}
	type x struct{}
	out := protoimpl.TypeBuilder{
		File: protoimpl.DescBuilder{
			GoPackagePath: reflect.TypeOf(x{}).PkgPath(),
			RawDescriptor: file_math_proto_rawDesc,
			NumEnums:      0,
			NumMessages:   2,
			NumExtensions: 0,
			NumServices:   1,
		},
		GoTypes:           file_math_proto_goTypes,
		DependencyIndexes: file_math_proto_depIdxs,
		MessageInfos:      file_math_proto_msgTypes,
	}.Build()
	File_math_proto = out.File
	file_math_proto_rawDesc = nil
	file_math_proto_goTypes = nil
	file_math_proto_depIdxs = nil
}

// Reference imports to suppress errors if they are not otherwise used.
var _ context.Context
var _ grpc.ClientConnInterface

// This is a compile-time assertion to ensure that this generated file
// is compatible with the grpc package it is being compiled against.
const _ = grpc.SupportPackageIsVersion6

// MathClient is the client API for Math service.
//
// For semantics around ctx use and closing/ending streaming RPCs, please refer to https://godoc.org/google.golang.org/grpc#ClientConn.NewStream.
type MathClient interface {
	Max(ctx context.Context, opts ...grpc.CallOption) (Math_MaxClient, error)
}

type mathClient struct {
	cc grpc.ClientConnInterface
}

func NewMathClient(cc grpc.ClientConnInterface) MathClient {
	return &mathClient{cc}
}

func (c *mathClient) Max(ctx context.Context, opts ...grpc.CallOption) (Math_MaxClient, error) {
	stream, err := c.cc.NewStream(ctx, &_Math_serviceDesc.Streams[0], "/protobuf.Math/Max", opts...)
	if err != nil {
		return nil, err
	}
	x := &mathMaxClient{stream}
	return x, nil
}

type Math_MaxClient interface {
	Send(*Request) error
	Recv() (*Response, error)
	grpc.ClientStream
}

type mathMaxClient struct {
	grpc.ClientStream
}

func (x *mathMaxClient) Send(m *Request) error {
	return x.ClientStream.SendMsg(m)
}

func (x *mathMaxClient) Recv() (*Response, error) {
	m := new(Response)
	if err := x.ClientStream.RecvMsg(m); err != nil {
		return nil, err
	}
	return m, nil
}

// MathServer is the server API for Math service.
type MathServer interface {
	Max(Math_MaxServer) error
}

// UnimplementedMathServer can be embedded to have forward compatible implementations.
type UnimplementedMathServer struct {
}

func (*UnimplementedMathServer) Max(Math_MaxServer) error {
	return status.Errorf(codes.Unimplemented, "method Max not implemented")
}

func RegisterMathServer(s *grpc.Server, srv MathServer) {
	s.RegisterService(&_Math_serviceDesc, srv)
}

func _Math_Max_Handler(srv interface{}, stream grpc.ServerStream) error {
	return srv.(MathServer).Max(&mathMaxServer{stream})
}

type Math_MaxServer interface {
	Send(*Response) error
	Recv() (*Request, error)
	grpc.ServerStream
}

type mathMaxServer struct {
	grpc.ServerStream
}

func (x *mathMaxServer) Send(m *Response) error {
	return x.ServerStream.SendMsg(m)
}

func (x *mathMaxServer) Recv() (*Request, error) {
	m := new(Request)
	if err := x.ServerStream.RecvMsg(m); err != nil {
		return nil, err
	}
	return m, nil
}

var _Math_serviceDesc = grpc.ServiceDesc{
	ServiceName: "protobuf.Math",
	HandlerType: (*MathServer)(nil),
	Methods:     []grpc.MethodDesc{},
	Streams: []grpc.StreamDesc{
		{
			StreamName:    "Max",
			Handler:       _Math_Max_Handler,
			ServerStreams: true,
			ClientStreams: true,
		},
	},
	Metadata: "math.proto",
}
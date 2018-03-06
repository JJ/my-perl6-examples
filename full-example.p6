use v6;
use NativeCall;

constant \INET_ADDRSTRLEN = 16;
constant \INET6_ADDRSTRLEN = 46;

enum AddrInfo-Family (
    AF_UNSPEC                   => 0;
    AF_INET                     => 2;
    AF_INET6                    => 10;
);

enum AddrInfo-Socktype (
    SOCK_STREAM                 => 1;
    SOCK_DGRAM                  => 2;
    SOCK_RAW                    => 3;
    SOCK_RDM                    => 4;
    SOCK_SEQPACKET              => 5;
    SOCK_DCCP                   => 6;
    SOCK_PACKET                 => 10;
);

enum AddrInfo-Flags (
    AI_PASSIVE                  => 0x0001;
    AI_CANONNAME                => 0x0002;
    AI_NUMERICHOST              => 0x0004;
    AI_V4MAPPED                 => 0x0008;
    AI_ALL                      => 0x0010;
    AI_ADDRCONFIG               => 0x0020;
    AI_IDN                      => 0x0040;
    AI_CANONIDN                 => 0x0080;
    AI_IDN_ALLOW_UNASSIGNED     => 0x0100;
    AI_IDN_USE_STD3_ASCII_RULES => 0x0200;
    AI_NUMERICSERV              => 0x0400;
);

sub inet_ntop(int32, Pointer, Blob, int32 --> Str)
    is native() {}

class SockAddr is repr('CStruct') {
    has uint16 $.sa_family;
}

class SockAddr-in is repr('CStruct') {
    has int16 $.sin_family;
    has uint16 $.sin_port;
    has uint32 $.sin_addr;

    method address {
        my $buf = buf8.allocate(INET_ADDRSTRLEN);
        inet_ntop(AF_INET, Pointer.new(nativecast(Pointer,self)+4),
            $buf, INET_ADDRSTRLEN)
    }
}

class SockAddr-in6 is repr('CStruct') {
    has uint16 $.sin6_family;
    has uint16 $.sin6_port;
    has uint32 $.sin6_flowinfo;
    has uint64 $.sin6_addr0;
    has uint64 $.sin6_addr1;
    has uint32 $.sin6_scope_id;

    method address {
        my $buf = buf8.allocate(INET6_ADDRSTRLEN);
        inet_ntop(AF_INET6, Pointer.new(nativecast(Pointer,self)+8),
            $buf, INET6_ADDRSTRLEN)
    }
}

class Addrinfo is repr('CStruct') {
    has int32 $.ai_flags;
    has int32 $.ai_family;
    has int32 $.ai_socktype;
    has int32 $.ai_protocol;
    has uint32 $.ai_addrNativeCalllen;
    has SockAddr $.ai_addr is rw;
    has Str $.ai_cannonname is rw;
    has Addrinfo $.ai_next is rw;

    method flags {
        do for AddrInfo-Flags.enums { .key if $!ai_flags +& .value }
    }

    method family {
        AddrInfo-Family($!ai_family)
    }

    method socktype {
        AddrInfo-Socktype($!ai_socktype)
    }

    method address {
        given $.family {
            when AF_INET {
                nativecast(SockAddr-in, $!ai_addr).address
            }
            when AF_INET6 {
                nativecast(SockAddr-in6, $!ai_addr).address
            }
        }
    }
}

sub getaddrinfo(Str $node, Str $service, Addrinfo $hints,
                Pointer $res is rw --> int32)
    is native() {};

sub freeaddrinfo(Pointer)
    is native() {}

sub MAIN() {
    my Addrinfo $hint .= new(:ai_flags(AI_CANONNAME));
    my Pointer $res .= new;
    my $rv = getaddrinfo("google.com", Str, $hint, $res);
    say "return val: $rv";
    if ( ! $rv ) {
        my $addr = nativecast(Addrinfo, $res);
        while $addr {
            with $addr {
                say "Name: ", $_ with .ai_cannonname;
                say .family, ' ', .socktype;
                say .address;
                $addr = .ai_next;
            }
        }
    }
    freeaddrinfo($res);
}

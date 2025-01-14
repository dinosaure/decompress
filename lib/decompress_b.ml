module Bigstring =
struct
  open Bigarray

  type t = (char, int8_unsigned_elt, c_layout) Array1.t

  let length = Array1.dim
  let create = Array1.create Char c_layout
  let get    = Array1.get
  let set    = Array1.set
  let sub    = Array1.sub
  let fill   = Array1.fill
  let copy v =
    let v' = create (length v) in
    Array1.blit v v'; v'

  external get_u16 : t -> int -> int     = "%caml_bigstring_get16u"

  let get_u16 t i =
    if i < 0 || i > length t - 2
    then raise (Invalid_argument "Bytes.get_u16")
    else get_u16 t i

  external get_u32 : t -> int -> Int32.t = "%caml_bigstring_get32u"

  let get_u32 t i =
    if i < 0 || i > length t - 4
    then raise (Invalid_argument "Bytes.get_u32")
    else get_u32 t i

  external get_u64 : t -> int -> Int64.t = "%caml_bigstring_get64u"

  let get_u64 t i =
    if i < 0 || i > length t - 8
    then raise (Invalid_argument "Bytes.get_u64")
    else get_u64 t i

  external set_u16 : t -> int -> int -> unit     = "%caml_bigstring_set16u"

  let set_u16 t i =
    if i < 0 || i > length t - 2
    then raise (Invalid_argument "Bytes.set_u16")
    else set_u16 t i

  external set_u32 : t -> int -> Int32.t -> unit = "%caml_bigstring_set32u"

  let set_u32 t i =
    if i < 0 || i > length t - 4
    then raise (Invalid_argument "Bytes.set_u32")
    else set_u32 t i

  external set_u64 : t -> int -> Int64.t -> unit = "%caml_bigstring_set64u"

  let set_u64 t i =
    if i < 0 || i > length t - 8
    then raise (Invalid_argument "Bytes.set_u64")
    else set_u64 t i

  let to_string v =
    let buf = Bytes.create (length v) in
    for i = 0 to length v - 1
    do Bytes.set buf i (get v i) done;
    Bytes.unsafe_to_string buf

  (* XXX: memcpy instead memmove *)
  let blit src src_off dst dst_off len =
    for i = 0 to len - 1
    do set dst (dst_off + i) (get src (src_off + i)) done

  let blit src src_off dst dst_off len =
    if len < 0 || src_off < 0 || src_off > length src - len
               || dst_off < 0 || dst_off > length dst - len
    then raise (Invalid_argument (Format.sprintf "Bigstring.blit (src: %d:%d, \
                                                                  dst: %d:%d, \
                                                                  len: %d)"
                                    src_off (length src)
                                    dst_off (length dst)
                                    len))
    else blit src src_off dst dst_off len

  let blit2 src src_off dst0 dst_off0 dst1 dst_off1 len =
    if len < 0 || src_off < 0  || src_off > length src - len
               || dst_off0 < 0 || dst_off0 > length dst0 - len
               || dst_off1 < 0 || dst_off1 > length dst1 - len
    then raise (Invalid_argument (Format.sprintf "Bigstring.blit2 (src: %d:%d, \
                                                                   dst0: %d:%d, \
                                                                   dst1 %d:%d, \
                                                                   len: %d)"
                                    src_off (length src)
                                    dst_off0 (length dst0)
                                    dst_off1 (length dst1)
                                    len))
    else for i = 0 to len - 1
      do
        set dst0 (dst_off0 + i) (get src (src_off + i));
        set dst1 (dst_off1 + i) (get src (src_off + i));
      done

  let pp fmt ba =
    for i = 0 to length ba - 1
    do Format.pp_print_char fmt (get ba i) done

  let empty = create 0
end


module Bytes =
struct
  include Bytes

  external get_u16 : t -> int -> int     = "%caml_string_get16u"

  let get_u16 t i =
    if i < 0 || i > length t - 2
    then raise (Invalid_argument "Bytes.get_u16")
    else get_u16 t i

  external get_u32 : t -> int -> Int32.t = "%caml_string_get32u"

  let get_u32 t i =
    if i < 0 || i > length t - 4
    then raise (Invalid_argument "Bytes.get_u32")
    else get_u32 t i

  external get_u64 : t -> int -> Int64.t = "%caml_string_get64u"

  let get_u64 t i =
    if i < 0 || i > length t - 8
    then raise (Invalid_argument "Bytes.get_u64")
    else get_u64 t i

  external set_u16 : t -> int -> int -> unit     = "%caml_string_set16u"

  let set_u16 t i =
    if i < 0 || i > length t - 2
    then raise (Invalid_argument "Bytes.set_u16")
    else set_u16 t i

  external set_u32 : t -> int -> Int32.t -> unit = "%caml_string_set32u"

  let set_u32 t i =
    if i < 0 || i > length t - 4
    then raise (Invalid_argument "Bytes.set_u32")
    else set_u32 t i

  external set_u64 : t -> int -> Int64.t -> unit = "%caml_string_set64u"

  let set_u64 t i =
    if i < 0 || i > length t - 8
    then raise (Invalid_argument "Bytes.set_u64")
    else set_u64 t i

  let pp fmt bs =
    for i = 0 to length bs - 1
    do Format.pp_print_char fmt (get bs i) done

  (* XXX: memcpy instead memmove *)
  let blit src src_off dst dst_off len =
    for i = 0 to len - 1
    do set dst (dst_off + i) (get src (src_off + i)) done

  let blit src src_off dst dst_off len =
    if len < 0 || src_off < 0 || src_off > length src - len
               || dst_off < 0 || dst_off > length dst - len
    then raise (Invalid_argument (Format.sprintf "Bytes.blit (src: %d:%d, \
                                                              dst: %d:%d, \
                                                              len: %d)"
                                    src_off (length src)
                                    dst_off (length dst)
                                    len))
    else blit src src_off dst dst_off len

  (* XXX(dinosaure): Consider than [src] and [dst] it's the same buffer (the window).
                     We need to use the [blit2] function when we have a match. Indeed,
                     previously, we have to case:

                     * update the window, then update the dst

                       This is wrong because for a large distance we write on
                       the old bytes of the window and but these old bytes are
                       not yet saved in the output.

                     * update the dst, then update the output

                       This is wrong too because may be you need the new bytes
                       of the window (for a short distance or close to the write
                       position of the window) and [blit] unbehaviour bytes to
                       dst.

                     So, per byte, we update firstly the window and, then the output.

   *)
  let blit2 src src_off dst0 dst_off0 dst1 dst_off1 len =
    if len < 0 || src_off < 0  || src_off > length src - len
               || dst_off0 < 0 || dst_off0 > length dst0 - len
               || dst_off1 < 0 || dst_off1 > length dst1 - len
    then raise (Invalid_argument (Format.sprintf "Bytes.blit2 (src: %d:%d, \
                                                               dst0: %d:%d, \
                                                               dst1 %d:%d, \
                                                               len: %d)"
                                    src_off (length src)
                                    dst_off0 (length dst0)
                                    dst_off1 (length dst1)
                                    len))
    else for i = 0 to len - 1
      do
        set dst0 (dst_off0 + i) (get src (src_off + i)); (* write the character in the window *)
        set dst1 (dst_off1 + i) (get src (src_off + i)); (* write the character in the output *)
      done
end

(* mandatory for a GADT *)
type st = St
type bs = Bs

type 'a t =
  | Bytes : Bytes.t -> st t
  | Bigstring : Bigstring.t -> bs t

let from_bytes v = Bytes v
let from_bigstring v = Bigstring v

let from
  : type a. proof:a t -> int -> a t
  = fun ~proof len -> match proof with
  | Bytes _ -> Bytes (Bytes.create len)
  | Bigstring _ -> Bigstring (Bigstring.create len)

let length
  : type a. a t -> int
  = function
  | Bytes v -> Bytes.length v
  | Bigstring v -> Bigstring.length v

let get
  : type a. a t -> int -> char
  = fun v idx -> match v with
  | Bytes v -> Bytes.get v idx
  | Bigstring v -> Bigstring.get v idx

let set
  : type a. a t -> int -> char -> unit
  = fun v idx chr -> match v with
  | Bytes v -> Bytes.set v idx chr
  | Bigstring v -> Bigstring.set v idx chr

let get_u16
  : type a. a t -> int -> int
  = fun v idx -> match v with
  | Bytes v -> Bytes.get_u16 v idx
  | Bigstring v -> Bigstring.get_u16 v idx

let get_u32
  : type a. a t -> int -> Int32.t
  = fun v idx -> match v with
  | Bytes v -> Bytes.get_u32 v idx
  | Bigstring v -> Bigstring.get_u32 v idx

let get_u64
  : type a. a t -> int -> Int64.t
  = fun v idx -> match v with
  | Bytes v -> Bytes.get_u64 v idx
  | Bigstring v -> Bigstring.get_u64 v idx

let set_u16
  : type a. a t -> int -> int -> unit
  = fun v idx u -> match v with
  | Bytes v -> Bytes.set_u16 v idx u
  | Bigstring v -> Bigstring.set_u16 v idx u

let set_u32
  : type a. a t -> int -> int32 -> unit
  = fun v idx u -> match v with
  | Bytes v -> Bytes.set_u32 v idx u
  | Bigstring v -> Bigstring.set_u32 v idx u

let set_u64
  : type a. a t -> int -> int64 -> unit
  = fun v idx u -> match v with
  | Bytes v -> Bytes.set_u64 v idx u
  | Bigstring v -> Bigstring.set_u64 v idx u

let sub
  : type a. a t -> int -> int -> a t
  = fun v off len -> match v with
  | Bytes v -> Bytes.sub v off len |> from_bytes
  | Bigstring v -> Bigstring.sub v off len |> from_bigstring

let fill
  : type a. a t -> int -> int -> char -> unit
  = fun v off len chr -> match v with
  | Bytes v -> Bytes.fill v off len chr
  | Bigstring v -> Bigstring.fill (Bigstring.sub v off len) chr

let blit
  : type a. a t -> int -> a t -> int -> int -> unit
  = fun src src_idx dst dst_idx len -> match src, dst with
  | Bytes src, Bytes dst ->
    Bytes.blit src src_idx dst dst_idx len
  | Bigstring src, Bigstring dst ->
    Bigstring.blit src src_idx dst dst_idx len

let blit2
  : type a. a t -> int -> a t -> int -> a t -> int -> int -> unit
  = fun src src_idx dst0 dst_idx0 dst1 dst_idx1  len -> match src, dst0, dst1 with
  | Bytes src, Bytes dst0, Bytes dst1 ->
    Bytes.blit2 src src_idx dst0 dst_idx0 dst1 dst_idx1 len
  | Bigstring src, Bigstring dst0, Bigstring dst1 ->
    Bigstring.blit2 src src_idx dst0 dst_idx0 dst1 dst_idx1 len

let pp
  : type a. Format.formatter -> a t -> unit
  = fun fmt -> function
  | Bytes v -> Format.fprintf fmt "%a" Bytes.pp v
  | Bigstring v -> Format.fprintf fmt "%a" Bigstring.pp v

let to_string
  : type a. a t -> string
  = function
  | Bytes v -> Bytes.to_string v
  | Bigstring v -> Bigstring.to_string v

let empty
  : type a. proof:a t -> a t
  = fun ~proof -> match proof with
  | Bytes _ -> Bytes Bytes.empty
  | Bigstring _ -> Bigstring Bigstring.empty

let proof_bytes = Bytes Bytes.empty
let proof_bigstring = Bigstring Bigstring.empty

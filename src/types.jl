"""
`struct parsing <: GNTParsings`\n

The `GNTParsings` module parsing internal representation.
"""
struct parsing <: GNTParsings
    pos::String     # Part of speech
    per::Char       # Person
    ten::Char       # Tense
    voi::Char       # Voice
    moo::Char       # Mood
    cas::Char       # Case
    num::Char       # Number
    gen::Char       # Gender
    deg::Char       # Degree
    # Internal (validating) constructor
    function parsing(pos::S, per::C, ten::C,
                     voi::C, moo::C, cas::C,
                     num::C, gen::C, deg::C) where {S<:AbstractString, C<:AbstractChar}
        cat = "$pos $per$ten$voi$moo$cas$num$gen$deg"
        @assert(
            pos in ("A-","C-","D-","I-","N-","P-","RA","RD","RI","RP","RR","V-","X-"),
            "'$cat': invalid part of speech '$pos'"
        )
        @assert(per in "-123"   , "'$cat': invalid person '$per'")
        @assert(ten in "-AFIPXY", "'$cat': invalid tense  '$ten'")
        @assert(voi in "-AMP"   , "'$cat': invalid voice  '$voi'")
        @assert(moo in "-DINOPS", "'$cat': invalid mood   '$moo'")
        @assert(cas in "-ADGNV" , "'$cat': invalid case   '$cas'")
        @assert(num in "-PS"    , "'$cat': invalid number '$num'")
        @assert(gen in "-FMN"   , "'$cat': invalid gender '$gen'")
        @assert(deg in "-CS"    , "'$cat': invalid degree '$deg'")
        return new(pos, per, ten, voi, moo, cas, num, gen, deg)
    end
end

export parsing

# External convenience constructors - two-arg splatting version
parsing(pos::X, par::Y) where {X<:AbstractString, Y<:AbstractString} = parsing(pos, par...)

# External convenience constructors - one-arg, space-delimited version
parsing(all::S) where S<:AbstractString = begin
    spl = split(all, limit=2)
    parsing(spl[1], join(split(spl[2]), ""))
end


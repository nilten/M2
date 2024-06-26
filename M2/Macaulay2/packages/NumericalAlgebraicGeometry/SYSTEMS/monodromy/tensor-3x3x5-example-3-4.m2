-- PATCH for M2 version 1.7
needsPackage "NumericalAlgebraicGeometry"
solutionsWithMultiplicity List := o-> sols -> ( 
    sorted := sortSolutions(sols,o);
    i := 0; 
    while i<#sorted list (
	si := sorted#i;
	si.Multiplicity = 1;
	j := i + 1;
	while j < #sorted and areEqual(sorted#j,si,o) do (
	    si.Multiplicity = si.Multiplicity + 1;
	    j = j + 1;
	    );
	i = j;
	si
	) 
    )
end --------------------------------------------------------------------------

-- START pushing F11 here
restart
load "tensor-3x3x5-decompositions.m2"

R = CC[v11,v12,v13, w11,w12,w13, u11,u12,u13,u14,u15,
       v21,v22,v23, w21,w22,w23, u21,u22,u23,u24,u25,
       v31,v32,v33, w31,w32,w33, u31,u32,u33,u34,u35,
       v41,v42,v43, w41,w42,w43, u41,u42,u43,u44,u45,
       v51,v52,v53, w51,w52,w53, u51,u52,u53,u54,u55] 
theF = matrix{
    flatten for v from 1 to 3 list 
    flatten for w from 1 to 3 list 
            for u from 1 to 5 list 
    sum for r from 1 to 5 list value("v"|r|v|"*"|"u"|r|u|"*"|"w"|r|w)
    };
-- "normalize": set some coordinates to 1 
varList = {
    v11,v12,v13,     w12,w13,     u12,u13,u14,u15,
    v21,v22,v23, w21,    w23, u21,    u23,u24,u25,
    v31,v32,v33, w31,w32,     u31,u32,    u34,u35,
    v41,v42,v43,     w42,w43, u41,u42,u43,    u45,
    v51,v52,v53,     w52,w53, u51,u52,u53,u54    
    };
indList = select(numgens R, i->member(R_i,varList))
theF = sub(theF, matrix{apply(gens R, t->if member(t,varList) then t else 1)});
assert(#varList==numcols theF) -- square system
RH = CC[varList] 
F = transpose sub(theF, RH)

setRandomSeed 0
needsPackage "NumericalAlgebraicGeometry"

-- create a generic pair (s0,T0) = (decomposition,tensor)
s0 = random(CC^1,CC^45);
T0 = sub(F,s0)

-- we know one decomposition at the moment:
sols0 = {point s0};

-* outsource to an external solver:
setDefault(Software=>BERTINI)
setDefault(Software=>PHCPACK)
*-

while #sols0 != 720 do (
    T1 = random(CC^45,CC^1);
    T2 = random(CC^45,CC^1);
    elapsedTime sols1 = track(polySystem(F-T0),polySystem(F-T1),sols0);
    elapsedTime sols2 = track(polySystem(F-T1),polySystem(F-T2),sols1);
    elapsedTime sols0' = track(polySystem(F-T2),polySystem(F-T0),sols2);
    assert all(sols0', s->norm(T0 - sub(F,matrix s)) < 1e-6); -- check T0 = F(s)
    sols0 = solutionsWithMultiplicity(sols0 | sols0'); -- take the union
    << "found " << #sols0 << " decompositions so far" << endl;
    )

A = matrix {{1,0,0,1,1},
            {0,1,0,1,2},
            {0,0,1,1,3}};
B = matrix {{1,0,0,1,1},
            {0,1,0,1,3},
            {0,0,1,1,5}};
C = id_(CC^5)

T' = sub(F,(flatten (A||B||C))_indList);
elapsedTime sols' = track(polySystem(F-T0),polySystem(F-T'),sols0);
elapsedTime sols' = track(polySystem(F-T0),polySystem(F-T'),sols0,Software=>BERTINI);
#sols'
msols' = solutionsWithMultiplicity select(sols',s->status s != Infinity);
#msols'

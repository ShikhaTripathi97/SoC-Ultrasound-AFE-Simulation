.ALIASES
X_U1            U1(+=N00557 -=N00523 V+=VCC V-=VEE OUT=N00540 ) CN
+@OPERATIONAL_AMPLIFIER.OpAmpSchematic(sch_1):INS196@OPAMP.uA741.Normal(chips)
V_V1            V1(+=VCC -=0 ) CN @OPERATIONAL_AMPLIFIER.OpAmpSchematic(sch_1):INS247@SOURCE.VDC.Normal(chips)
V_V2            V2(+=VEE -=0 ) CN @OPERATIONAL_AMPLIFIER.OpAmpSchematic(sch_1):INS263@SOURCE.VDC.Normal(chips)
R_R1            R1(1=0 2=N00523 ) CN @OPERATIONAL_AMPLIFIER.OpAmpSchematic(sch_1):INS423@ANALOG.R.Normal(chips)
R_R2            R2(1=N00523 2=N00540 ) CN @OPERATIONAL_AMPLIFIER.OpAmpSchematic(sch_1):INS449@ANALOG.R.Normal(chips)
V_V3            V3(+=N00557 -=0 ) CN @OPERATIONAL_AMPLIFIER.OpAmpSchematic(sch_1):INS480@SOURCE.VSIN.Normal(chips)
R_R3            R3(1=0 2=N00540 ) CN @OPERATIONAL_AMPLIFIER.OpAmpSchematic(sch_1):INS625@ANALOG.R.Normal(chips)
_    _(VCC=VCC)
_    _(VEE=VEE)
.ENDALIASES

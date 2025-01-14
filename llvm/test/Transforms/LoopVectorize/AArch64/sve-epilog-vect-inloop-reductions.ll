; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt < %s -loop-vectorize -mtriple aarch64-unknown-linux-gnu -mattr=+sve -epilogue-vectorization-force-VF=2 -prefer-inloop-reductions -S | FileCheck %s

;
; In-loop integer and reduction
;
define i64 @int_reduction_and(i64* noalias nocapture %a, i64 %N) {
; CHECK-LABEL: @int_reduction_and(
; CHECK-NEXT:  iter.check:
; CHECK-NEXT:    [[MIN_ITERS_CHECK:%.*]] = icmp ult i64 [[N:%.*]], 2
; CHECK-NEXT:    br i1 [[MIN_ITERS_CHECK]], label [[VEC_EPILOG_SCALAR_PH:%.*]], label [[VECTOR_MAIN_LOOP_ITER_CHECK:%.*]]
; CHECK:       vector.main.loop.iter.check:
; CHECK-NEXT:    [[TMP0:%.*]] = call i64 @llvm.vscale.i64()
; CHECK-NEXT:    [[TMP1:%.*]] = mul i64 [[TMP0]], 4
; CHECK-NEXT:    [[MIN_ITERS_CHECK1:%.*]] = icmp ult i64 [[N]], [[TMP1]]
; CHECK-NEXT:    br i1 [[MIN_ITERS_CHECK1]], label [[VEC_EPILOG_PH:%.*]], label [[VECTOR_PH:%.*]]
; CHECK:       vector.ph:
; CHECK-NEXT:    [[TMP2:%.*]] = call i64 @llvm.vscale.i64()
; CHECK-NEXT:    [[TMP3:%.*]] = mul i64 [[TMP2]], 4
; CHECK-NEXT:    [[N_MOD_VF:%.*]] = urem i64 [[N]], [[TMP3]]
; CHECK-NEXT:    [[N_VEC:%.*]] = sub i64 [[N]], [[N_MOD_VF]]
; CHECK-NEXT:    br label [[VECTOR_BODY:%.*]]
; CHECK:       vector.body:
; CHECK-NEXT:    [[INDEX:%.*]] = phi i64 [ 0, [[VECTOR_PH]] ], [ [[INDEX_NEXT:%.*]], [[VECTOR_BODY]] ]
; CHECK-NEXT:    [[VEC_PHI:%.*]] = phi i64 [ 1, [[VECTOR_PH]] ], [ [[TMP19:%.*]], [[VECTOR_BODY]] ]
; CHECK-NEXT:    [[VEC_PHI2:%.*]] = phi i64 [ -1, [[VECTOR_PH]] ], [ [[TMP21:%.*]], [[VECTOR_BODY]] ]
; CHECK-NEXT:    [[TMP4:%.*]] = add i64 [[INDEX]], 0
; CHECK-NEXT:    [[TMP5:%.*]] = call i64 @llvm.vscale.i64()
; CHECK-NEXT:    [[TMP6:%.*]] = mul i64 [[TMP5]], 2
; CHECK-NEXT:    [[TMP7:%.*]] = add i64 [[TMP6]], 0
; CHECK-NEXT:    [[TMP8:%.*]] = mul i64 [[TMP7]], 1
; CHECK-NEXT:    [[TMP9:%.*]] = add i64 [[INDEX]], [[TMP8]]
; CHECK-NEXT:    [[TMP10:%.*]] = getelementptr inbounds i64, i64* [[A:%.*]], i64 [[TMP4]]
; CHECK-NEXT:    [[TMP11:%.*]] = getelementptr inbounds i64, i64* [[A]], i64 [[TMP9]]
; CHECK-NEXT:    [[TMP12:%.*]] = getelementptr inbounds i64, i64* [[TMP10]], i32 0
; CHECK-NEXT:    [[TMP13:%.*]] = bitcast i64* [[TMP12]] to <vscale x 2 x i64>*
; CHECK-NEXT:    [[WIDE_LOAD:%.*]] = load <vscale x 2 x i64>, <vscale x 2 x i64>* [[TMP13]], align 4
; CHECK-NEXT:    [[TMP14:%.*]] = call i32 @llvm.vscale.i32()
; CHECK-NEXT:    [[TMP15:%.*]] = mul i32 [[TMP14]], 2
; CHECK-NEXT:    [[TMP16:%.*]] = getelementptr inbounds i64, i64* [[TMP10]], i32 [[TMP15]]
; CHECK-NEXT:    [[TMP17:%.*]] = bitcast i64* [[TMP16]] to <vscale x 2 x i64>*
; CHECK-NEXT:    [[WIDE_LOAD3:%.*]] = load <vscale x 2 x i64>, <vscale x 2 x i64>* [[TMP17]], align 4
; CHECK-NEXT:    [[TMP18:%.*]] = call i64 @llvm.vector.reduce.and.nxv2i64(<vscale x 2 x i64> [[WIDE_LOAD]])
; CHECK-NEXT:    [[TMP19]] = and i64 [[TMP18]], [[VEC_PHI]]
; CHECK-NEXT:    [[TMP20:%.*]] = call i64 @llvm.vector.reduce.and.nxv2i64(<vscale x 2 x i64> [[WIDE_LOAD3]])
; CHECK-NEXT:    [[TMP21]] = and i64 [[TMP20]], [[VEC_PHI2]]
; CHECK-NEXT:    [[TMP22:%.*]] = call i64 @llvm.vscale.i64()
; CHECK-NEXT:    [[TMP23:%.*]] = mul i64 [[TMP22]], 4
; CHECK-NEXT:    [[INDEX_NEXT]] = add nuw i64 [[INDEX]], [[TMP23]]
; CHECK-NEXT:    [[TMP24:%.*]] = icmp eq i64 [[INDEX_NEXT]], [[N_VEC]]
; CHECK-NEXT:    br i1 [[TMP24]], label [[MIDDLE_BLOCK:%.*]], label [[VECTOR_BODY]], !llvm.loop [[LOOP0:![0-9]+]]
; CHECK:       middle.block:
; CHECK-NEXT:    [[BIN_RDX:%.*]] = and i64 [[TMP21]], [[TMP19]]
; CHECK-NEXT:    [[CMP_N:%.*]] = icmp eq i64 [[N]], [[N_VEC]]
; CHECK-NEXT:    br i1 [[CMP_N]], label [[FOR_END:%.*]], label [[VEC_EPILOG_ITER_CHECK:%.*]]
; CHECK:       vec.epilog.iter.check:
; CHECK-NEXT:    [[N_VEC_REMAINING:%.*]] = sub i64 [[N]], [[N_VEC]]
; CHECK-NEXT:    [[MIN_EPILOG_ITERS_CHECK:%.*]] = icmp ult i64 [[N_VEC_REMAINING]], 2
; CHECK-NEXT:    br i1 [[MIN_EPILOG_ITERS_CHECK]], label [[VEC_EPILOG_SCALAR_PH]], label [[VEC_EPILOG_PH]]
; CHECK:       vec.epilog.ph:
; CHECK-NEXT:    [[BC_MERGE_RDX:%.*]] = phi i64 [ 1, [[VECTOR_MAIN_LOOP_ITER_CHECK]] ], [ [[BIN_RDX]], [[VEC_EPILOG_ITER_CHECK]] ]
; CHECK-NEXT:    [[VEC_EPILOG_RESUME_VAL:%.*]] = phi i64 [ [[N_VEC]], [[VEC_EPILOG_ITER_CHECK]] ], [ 0, [[VECTOR_MAIN_LOOP_ITER_CHECK]] ]
; CHECK-NEXT:    [[N_MOD_VF5:%.*]] = urem i64 [[N]], 2
; CHECK-NEXT:    [[N_VEC6:%.*]] = sub i64 [[N]], [[N_MOD_VF5]]
; CHECK-NEXT:    br label [[VEC_EPILOG_VECTOR_BODY:%.*]]
; CHECK:       vec.epilog.vector.body:
; CHECK-NEXT:    [[OFFSET_IDX:%.*]] = phi i64 [ [[VEC_EPILOG_RESUME_VAL]], [[VEC_EPILOG_PH]] ], [ [[INDEX_NEXT11:%.*]], [[VEC_EPILOG_VECTOR_BODY]] ]
; CHECK-NEXT:    [[VEC_PHI9:%.*]] = phi i64 [ [[BC_MERGE_RDX]], [[VEC_EPILOG_PH]] ], [ [[TMP30:%.*]], [[VEC_EPILOG_VECTOR_BODY]] ]
; CHECK-NEXT:    [[TMP25:%.*]] = add i64 [[OFFSET_IDX]], 0
; CHECK-NEXT:    [[TMP26:%.*]] = getelementptr inbounds i64, i64* [[A]], i64 [[TMP25]]
; CHECK-NEXT:    [[TMP27:%.*]] = getelementptr inbounds i64, i64* [[TMP26]], i32 0
; CHECK-NEXT:    [[TMP28:%.*]] = bitcast i64* [[TMP27]] to <2 x i64>*
; CHECK-NEXT:    [[WIDE_LOAD10:%.*]] = load <2 x i64>, <2 x i64>* [[TMP28]], align 4
; CHECK-NEXT:    [[TMP29:%.*]] = call i64 @llvm.vector.reduce.and.v2i64(<2 x i64> [[WIDE_LOAD10]])
; CHECK-NEXT:    [[TMP30]] = and i64 [[TMP29]], [[VEC_PHI9]]
; CHECK-NEXT:    [[INDEX_NEXT11]] = add nuw i64 [[OFFSET_IDX]], 2
; CHECK-NEXT:    [[TMP31:%.*]] = icmp eq i64 [[INDEX_NEXT11]], [[N_VEC6]]
; CHECK-NEXT:    br i1 [[TMP31]], label [[VEC_EPILOG_MIDDLE_BLOCK:%.*]], label [[VEC_EPILOG_VECTOR_BODY]], !llvm.loop [[LOOP2:![0-9]+]]
; CHECK:       vec.epilog.middle.block:
; CHECK-NEXT:    [[CMP_N7:%.*]] = icmp eq i64 [[N]], [[N_VEC6]]
; CHECK-NEXT:    br i1 [[CMP_N7]], label [[FOR_END_LOOPEXIT:%.*]], label [[VEC_EPILOG_SCALAR_PH]]
; CHECK:       vec.epilog.scalar.ph:
; CHECK-NEXT:    [[BC_RESUME_VAL:%.*]] = phi i64 [ [[N_VEC6]], [[VEC_EPILOG_MIDDLE_BLOCK]] ], [ [[N_VEC]], [[VEC_EPILOG_ITER_CHECK]] ], [ 0, [[ITER_CHECK:%.*]] ]
; CHECK-NEXT:    [[BC_MERGE_RDX12:%.*]] = phi i64 [ 1, [[ITER_CHECK]] ], [ [[BIN_RDX]], [[VEC_EPILOG_ITER_CHECK]] ], [ [[TMP30]], [[VEC_EPILOG_MIDDLE_BLOCK]] ]
; CHECK-NEXT:    br label [[FOR_BODY:%.*]]
; CHECK:       for.body:
; CHECK-NEXT:    [[IV:%.*]] = phi i64 [ [[IV_NEXT:%.*]], [[FOR_BODY]] ], [ [[BC_RESUME_VAL]], [[VEC_EPILOG_SCALAR_PH]] ]
; CHECK-NEXT:    [[RDX:%.*]] = phi i64 [ [[AND:%.*]], [[FOR_BODY]] ], [ [[BC_MERGE_RDX12]], [[VEC_EPILOG_SCALAR_PH]] ]
; CHECK-NEXT:    [[L2:%.*]] = getelementptr inbounds i64, i64* [[A]], i64 [[IV]]
; CHECK-NEXT:    [[L3:%.*]] = load i64, i64* [[L2]], align 4
; CHECK-NEXT:    [[AND]] = and i64 [[RDX]], [[L3]]
; CHECK-NEXT:    [[IV_NEXT]] = add i64 [[IV]], 1
; CHECK-NEXT:    [[EXITCOND:%.*]] = icmp eq i64 [[IV_NEXT]], [[N]]
; CHECK-NEXT:    br i1 [[EXITCOND]], label [[FOR_END_LOOPEXIT]], label [[FOR_BODY]], !llvm.loop [[LOOP4:![0-9]+]]
; CHECK:       for.end.loopexit:
; CHECK-NEXT:    [[AND_LCSSA4:%.*]] = phi i64 [ [[AND]], [[FOR_BODY]] ], [ [[TMP30]], [[VEC_EPILOG_MIDDLE_BLOCK]] ]
; CHECK-NEXT:    br label [[FOR_END]]
; CHECK:       for.end:
; CHECK-NEXT:    [[AND_LCSSA:%.*]] = phi i64 [ [[BIN_RDX]], [[MIDDLE_BLOCK]] ], [ [[AND_LCSSA4]], [[FOR_END_LOOPEXIT]] ]
; CHECK-NEXT:    ret i64 [[AND_LCSSA]]
;
entry:
  br label %for.body

for.body:
  %iv = phi i64 [ %iv.next, %for.body ], [ 0, %entry ]
  %rdx = phi i64 [ %and, %for.body ], [ 1, %entry ]
  %l2 = getelementptr inbounds i64, i64* %a, i64 %iv
  %l3 = load i64, i64* %l2
  %and = and i64 %rdx, %l3
  %iv.next = add i64 %iv, 1
  %exitcond = icmp eq i64 %iv.next, %N
  br i1 %exitcond, label %for.end, label %for.body

for.end:
  ret i64 %and
}

!0 = distinct !{!0, !1, !2}
!1 = !{!"llvm.loop.interleave.count", i32 2}
!2 = !{!"llvm.loop.vectorize.scalable.enable", i1 true}

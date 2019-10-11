program XTestALGLIB;
{$IFDEF FPC}
{$MODE OBJFPC}
{$ELSE}
{$ENDIF}
{$APPTYPE CONSOLE}

uses
    SysUtils, Classes, Math, XALGLIB, dateutils;
    
function StrIfThen(Cond: Boolean; STrue, SFalse: string):string;
begin
    if Cond then
        Result:=STrue
    else
        Result:=SFalse;
end;
    
////////////////////////////////////
// On failure returns False.
// On success returns True.
// May throw exception on internal error (must be catched by caller).
////////////
function BasicTests1D():Boolean;
var
    max1d : Integer;
    N, I, Cnt: Integer;
    ISum: TALGLIBInteger;
    RSum: Double;
    CSum: Complex;
    BArr0, BArr1, BArr2, BArr3: TBVector;
    IArr0, IArr1, IArr2, IArr3: TIVector;
    RArr0, RArr1, RArr2, RArr3: TVector;
    CArr0, CArr1, CArr2, CArr3: TCVector;
begin
    Result:=True;
    max1d:=70;
    
    //
    // Test exchange by 1D boolean arrays
    //
    for n:=0 to max1d do
    begin
        SetLength(BArr0, N);
        SetLength(BArr1, N);
        SetLength(BArr2, N);
        BArr3:=nil;
        cnt:=0;
        for i:=0 to N-1 do
        begin
            BArr0[i]:=Random()>0.5;
            BArr1[i]:=BArr0[i];
            BArr2[i]:=BArr0[i];
            if BArr0[i] then
                Inc(Cnt);
        end;
        Result:=Result and (xdebugb1count(BArr0)=Cnt);
        xdebugb1not(Barr1);
        if XLen(Barr1)=n then
        begin
            for i:=0 to n-1 do
                Result:=Result and (BArr1[i] xor BArr0[i]); // Arr1<>Arr0
        end
        else
            Result:=False;
        xdebugb1appendcopy(BArr2);
        if XLen(BArr2)=2*n then
        begin
            for i:=0 to 2*n-1 do
                Result := Result and not (BArr2[i] xor BArr0[i mod n]); //Arr2=Arr0
        end
        else
            Result := False;
        xdebugb1outeven(n, Barr3);
        if XLen(Barr3)=n then
        begin
            for i:=0 to n-1 do
                Result := Result and not (Barr3[i] xor ((i mod 2)=0));
        end
        else
            Result:=False;
    end;
    WriteLn('* boolean 1D arrays          '+StrIfThen(Result, 'OK', 'FAILED'));
    if not Result then
        Exit;
    
    //
    // Test exchange by integer 1D arrays
    //
    for n:=0 to max1d do
    begin
        SetLength(IArr0, N);
        SetLength(IArr1, N);
        SetLength(IArr2, N);
        IArr3:=nil;
        ISum:=0;
        for i:=0 to N-1 do
        begin
            IArr0[i]:=Random(10);
            IArr1[i]:=IArr0[i];
            IArr2[i]:=IArr0[i];
            ISum:=ISum+IArr0[i];
        end;
        Result:=Result and (xdebugi1sum(IArr0)=ISum);
        xdebugi1neg(IArr1);
        if XLen(IArr1)=n then
        begin
            for i:=0 to N-1 do
                Result:=Result and (IArr1[i]=-IArr0[i]);
        end
        else
            Result:=False;
        xdebugi1appendcopy(IArr2);
        if XLen(IArr2)=2*n then
        begin
            for i:=0 to 2*n-1 do
                Result:=Result and (IArr2[i]=IArr0[i mod n]);
        end
        else
            Result:=False;
        xdebugi1outeven(n, IArr3);
        if XLen(IArr3)=n then
        begin
            for i:=0 to n-1 do
                if (i mod 2)=0 then
                    Result:=Result and (IArr3[i]=i)
                else
                    Result:=Result and (IArr3[i]=0);
        end
        else
            Result:=False;
    end;
    WriteLn('* integer 1D arrays          '+StrIfThen(Result, 'OK', 'FAILED'));
    if not Result then
        Exit;
        
    //
    // Test exchange by real 1D arrays
    //
    for n:=0 to Max1D do
    begin
        SetLength(RArr0, N);
        SetLength(RArr1, N);
        SetLength(RArr2, N);
        RArr3:=nil;
        RSum:=0;
        for i:=0 to N-1 do
        begin
            Rarr0[i]:=Random()-0.5;
            Rarr1[i]:=Rarr0[i];
            Rarr2[i]:=Rarr0[i];
            Rsum:=Rsum+Rarr0[i];
        end;
        Result:=Result and (Abs(xdebugr1sum(Rarr0)-Rsum)<1.0E-10);
        xdebugr1neg(Rarr1);
        if Xlen(Rarr1)=n then
        begin
            for i:=0 to n-1 do
                Result:=Result and (Abs(Rarr1[i]+Rarr0[i])<1.0E-10);
        end
        else
            Result:=false;
        xdebugr1appendcopy(Rarr2);
        if Xlen(Rarr2)=2*n then
        begin
            for i:=0 to 2*n-1 do
                Result:=Result and (Rarr2[i]=Rarr0[i mod n]);
        end
        else
            Result:=false;
        xdebugr1outeven(n,Rarr3);
        if Xlen(Rarr3)=n then
        begin
            for i:=0 to n-1 do
                if (i mod 2)=0 then
                    Result:=Result and (Rarr3[i]=i*0.25)
                else
                    Result:=Result and (Rarr3[i]=0);
        end
        else
            Result:=False;
    end;
    WriteLn('* real 1D arrays             '+StrIfThen(Result, 'OK', 'FAILED'));
    if not Result then
        Exit;
        
    //
    // Complex 1D arrays
    //
    for n:=0 to Max1D do
    begin
        SetLength(Carr0, N);
        SetLength(Carr1, N);
        SetLength(Carr2, N);
        Carr3:=nil;
        Csum:=C_Complex(0);
        for i:=0 to N-1 do
        begin
            Carr0[i].x := Random()-0.5;
            Carr0[i].y := Random()-0.5;
            Carr1[i] := Carr0[i];
            Carr2[i] := Carr0[i];
            Csum:=C_Add(Csum,Carr0[i]);
        end;
        Result := Result and (C_abs(C_Sub(xdebugc1sum(Carr0),Csum))<1.0E-10);
        xdebugc1neg(Carr1);
        if xlen(Carr1)=n then
        begin
            for i:=0 to N-1 do
                Result := Result and (C_abs(C_add(Carr1[i],Carr0[i]))<1.0E-10);
        end
        else
            Result := false;
        xdebugc1appendcopy(Carr2);
        if xlen(Carr2)=2*n then
        begin
            for i:=0 to 2*n-1 do
                Result := Result and C_Equal(Carr2[i],Carr0[i mod n]);
        end
        else
            Result := false;
        xdebugc1outeven(n,Carr3);
        if xlen(Carr3)=n then
        begin
            for i:=0 to n-1 do
                if (i mod 2)=0 then
                    Result := Result and (Carr3[i].x=i*0.250) and (Carr3[i].y=i*0.125)
                else
                    Result := Result and (Carr3[i].x=0) and (Carr3[i].y=0);
        end
        else
            Result := false;
    end;
    WriteLn('* complex 1D arrays          '+StrIfThen(Result, 'OK', 'FAILED'));
    if not Result then
        Exit;
end;

////////////////////////////////////
// On failure returns False.
// On success returns True.
// May throw exception on internal error (must be catched by caller).
////////////
function BasicTests2D():Boolean;
var
    max2d : Integer;
    M, N, I, J, Cnt: Integer;
    ISum: TALGLIBInteger;
    RSum: Double;
    CSum: Complex;
    BArr0, BArr1, BArr2, BArr3: TBMatrix;
    IArr0, IArr1, IArr2, IArr3: TIMatrix;
    RArr0, RArr1, RArr2, RArr3: TMatrix;
    CArr0, CArr1, CArr2, CArr3: TCMatrix;
begin
    Result:=True;
    max2d:=40;
    
    //
    // Test exchange by 2D boolean arrays
    //
    for n:=0 to max2d do
        for m:=0 to max2d do
        begin
            // skip situations when n*m==0, but n!=0 or m!=0
            if (n*m=0) and ((n<>0) or (m<>0)) then
                Continue;
            
            // proceed to testing
            SetLength(Barr0, M, N);
            SetLength(Barr1, M, N);
            SetLength(Barr2, M, N);
            Barr3:=nil;
            cnt := 0;
            for i:=0 to m-1 do
                for j:=0 to n-1 do
                begin
                    Barr0[i,j] := random()>0.5;
                    Barr1[i,j] := Barr0[i,j];
                    Barr2[i,j] := Barr0[i,j];
                    if Barr0[i,j] then
                        Inc(Cnt);
                end;
            Result := Result and (xdebugb2count(Barr0)=cnt);
            xdebugb2not(Barr1);
            if (xrows(Barr1)=m) and (xcols(Barr1)=n) then
            begin
                for i:=0 to M-1 do
                    for J:=0 to N-1 do
                        Result := Result and (Barr1[i,j] xor Barr0[i,j]);
            end
            else
                Result := false;
            xdebugb2transpose(Barr2);
            if (xrows(Barr2)=n) and (xcols(Barr2)=m) then
            begin
                for i:=0 to M-1 do
                    for J:=0 to N-1 do
                        Result := Result and not (Barr2[j,i] xor Barr0[i,j]);
            end
            else
                Result := false;
            xdebugb2outsin(m, n, Barr3);
            if (xrows(Barr3)=m) and (xcols(Barr3)=n) then
            begin
                for i:=0 to M-1 do
                    for J:=0 to N-1 do
                        Result := Result and not (Barr3[i,j] xor (Sin(3*i+5*j)>0));
            end
            else
                Result := false;
        end;
    WriteLn('* boolean 2D arrays          '+StrIfThen(Result, 'OK', 'FAILED'));
    if not Result then
        Exit;
        
    //
    // Test exchange by integer arrays
    //
    for n:=0 to max2d do
        for m:=0 to max2d do
        begin
            // skip situations when n*m==0, but n!=0 or m!=0
            if (n*m=0) and ((n<>0) or (m<>0)) then
                Continue;
            
            // proceed to testing
            SetLength(Iarr0, M, N);
            SetLength(Iarr1, M, N);
            SetLength(Iarr2, M, N);
            Iarr3:=nil;
            Isum := 0;
            for i:=0 to M-1 do
                for J:=0 to N-1 do
                begin
                    Iarr0[i,j] := random(10);
                    Iarr1[i,j] := Iarr0[i,j];
                    Iarr2[i,j] := Iarr0[i,j];
                    Isum := Isum+Iarr0[i,j];
                end;
            Result := Result and (xdebugi2sum(Iarr0)=Isum);
            xdebugi2neg(Iarr1);
            if (xrows(Iarr1)=m) and (xcols(Iarr1)=n) then
            begin
                for i:=0 to M-1 do
                    for J:=0 to N-1 do
                        Result := Result and (Iarr1[i,j]=-Iarr0[i,j]);
            end
            else
                Result := false;
            xdebugi2transpose(Iarr2);
            if (xrows(Iarr2)=n) and (xcols(Iarr2)=m) then
            begin
                for i:=0 to M-1 do
                    for J:=0 to N-1 do
                        Result := Result and (Iarr2[j,i]=Iarr0[i,j]);
            end
            else
                Result := false;
            xdebugi2outsin(m, n, Iarr3);
            if (xrows(Iarr3)=m) and (xcols(Iarr3)=n) then
            begin
                for i:=0 to M-1 do
                    for J:=0 to N-1 do
                        Result := Result and (Iarr3[i,j]=Sign(Sin(3*i+5*j)));
            end
            else
                Result := false;
        end;
    WriteLn('* integer 2D arrays          '+StrIfThen(Result, 'OK', 'FAILED'));
    if not Result then
        Exit;
        
    //
    // Test exchange by real arrays
    //
    for n:=0 to max2d do
        for m:=0 to max2d do
        begin
            // skip situations when n*m==0, but n!=0 or m!=0
            if (n*m=0) and ((n<>0) or (m<>0)) then
                Continue;
            
            // proceed to testing
            SetLength(Rarr0, M, N);
            SetLength(Rarr1, M, N);
            SetLength(Rarr2, M, N);
            Rarr3:=nil;
            Rsum := 0;
            for i:=0 to M-1 do
                for J:=0 to N-1 do
                begin
                    Rarr0[i,j] := random()-0.5;
                    Rarr1[i,j] := Rarr0[i,j];
                    Rarr2[i,j] := Rarr0[i,j];
                    Rsum := Rsum+Rarr0[i,j];
                end;
            Result := Result and (Abs(xdebugr2sum(Rarr0)-Rsum)<1.0E-10);
            xdebugr2neg(Rarr1);
            if (xrows(Rarr1)=m) and (xcols(Rarr1)=n) then
            begin
                for i:=0 to M-1 do
                    for J:=0 to N-1 do
                        Result := Result and (Rarr1[i,j]=-Rarr0[i,j]);
            end
            else
                Result := false;
            xdebugr2transpose(Rarr2);
            if (xrows(Rarr2)=n) and (xcols(Rarr2)=m) then
            begin
                for i:=0 to M-1 do
                    for J:=0 to N-1 do
                        Result := Result and (Rarr2[j,i]=Rarr0[i,j]);
            end
            else
                Result := false;
            xdebugr2outsin(m, n, Rarr3);
            if (xrows(Rarr3)=m) and (xcols(Rarr3)=n) then
            begin
                for i:=0 to M-1 do
                    for J:=0 to N-1 do
                        Result := Result and (Abs(Rarr3[i,j]-Sin(3*i+5*j))<1E-10);
            end
            else
                Result := false;
        end;
    WriteLn('* real 2D arrays             '+StrIfThen(Result, 'OK', 'FAILED'));
    if not Result then
        Exit;
    
    //
    // Test exchange by complex arrays
    //
    for n:=0 to max2d do
        for m:=0 to max2d do
        begin
            // skip situations when n*m==0, but n!=0 or m!=0
            if (n*m=0) and ((n<>0) or (m<>0)) then
                Continue;
            
            // proceed to testing
            SetLength(Carr0, M, N);
            SetLength(Carr1, M, N);
            SetLength(Carr2, M, N);
            Carr3:=nil;
            Csum := C_Complex(0);
            for i:=0 to M-1 do
                for J:=0 to N-1 do
                begin
                    Carr0[i,j].x := random()-0.5;
                    Carr0[i,j].y := random()-0.5;
                    Carr1[i,j] := Carr0[i,j];
                    Carr2[i,j] := Carr0[i,j];
                    Csum := C_Add(Csum,Carr0[i,j]);
                end;
            Result := Result and (C_Abs(C_Sub(xdebugc2sum(Carr0),Csum))<1.0E-10);
            xdebugc2neg(Carr1);
            if (xrows(Carr1)=m) and (xcols(Carr1)=n) then
            begin
                for i:=0 to M-1 do
                    for J:=0 to N-1 do
                        Result := Result and (Carr1[i,j].x=-Carr0[i,j].x) and (Carr1[i,j].y=-Carr0[i,j].y);
            end
            else
                Result := False;
            xdebugc2transpose(Carr2);
            if (xrows(Carr2)=n) and (xcols(Carr2)=m) then
            begin
                for i:=0 to M-1 do
                    for J:=0 to N-1 do
                        Result := Result and C_Equal(Carr2[j,i],Carr0[i,j]);
            end
            else
                Result := false;
            xdebugc2outsincos(m, n, Carr3);
            if (xrows(Carr3)=m) and (xcols(Carr3)=n) then
            begin
                for i:=0 to M-1 do
                    for J:=0 to N-1 do
                    begin
                        Result := Result and (Abs(Carr3[i,j].x-Sin(3*i+5*j))<1E-10);
                        Result := Result and (Abs(Carr3[i,j].y-Cos(3*i+5*j))<1E-10);
                    end;
            end
            else
                Result := false;
        end;
    WriteLn('* complex 2D arrays          '+StrIfThen(Result, 'OK', 'FAILED'));
    if not Result then
        Exit;
end;

////////////////////////////////////
// On failure returns False.
// On success returns True.
// May throw exception on internal error (must be catched by caller).
////////////
function BasicTestsOther():Boolean;
var
    max2d : Integer;
    M, N, I, J: Integer;
    RSum: Double;
    A, B: TMatrix;
    C: TBMatrix;
begin
    Result:=True;
    max2d:=40;
    
    //
    // "biased product / sum" test
    //
    for n:=1 to max2d do
        for m:=1 to max2d do
        begin
            SetLength(A, M, N);
            SetLength(B, M, N);
            SetLength(C, M, N);
            Rsum:=0;
            for i:=0 to m-1 do
                for j:=0 to n-1 do
                begin
                    a[i,j] := random()-0.5;
                    b[i,j] := random()-0.5;
                    c[i,j] := random()>0.5;
                    if c[i,j] then
                        Rsum := Rsum+a[i,j]*(1+b[i,j]);
                end;
            Result:=Result and (Abs(xdebugmaskedbiasedproductsum(m,n,a,b,c)-Rsum)<1.0E-10);
        end;
    WriteLn('* multiple arrays            '+StrIfThen(Result, 'OK', 'FAILED'));
    if not Result then
        Exit;
end;


////////////////////////////////////
//
// Tests serialization functionality (using kd-trees as playground)
//
// On failure returns False.
// On success returns True.
// May throw exception on internal error (must be catched by caller).
////////////
function KDTreeSerializationTests():Boolean;
var
    rs:         Thqrndstate;
    tree0, tree1: Tkdtree;
    xy, rxy0, rxy1: TMatrix;
    qx:         TVector;
    NPts:       TALGLIBInteger;
    NX:         TALGLIBInteger;
    NY:         TALGLIBInteger;
    Cnt0, Cnt1: TALGLIBInteger;
    I, J:       TALGLIBInteger;
    S:          AnsiString;
    MS:         TMemoryStream;
    C:          AnsiChar;
begin
    Result:=True;
    NPts:= 50;
    NX:= 2;
    NY:= 1;
    
    //
    // Prepare kd-tree data
    //
    hqrndrandomize(rs);
    SetLength(xy, npts, nx+ny);
    for I:=0 to NPts-1 do
        for J:=0 to NX+NY-1 do
            XY[I,J]:=hqrndnormal(rs);
    kdtreebuild(xy, npts, nx, ny, 2, tree0);
    SetLength(QX, NX);
    
    //
    // Test string serialization/unserialization
    //
    tree1:=nil;
    s:='';
    kdtreeserialize(tree0, s);
    kdtreeunserialize(s, tree1);
    for I:=0 to 99 do
    begin
        for J:=0 to NX-1 do
            qx[j] := hqrndnormal(rs);
        cnt0 := kdtreequeryknn(tree0, qx, 1, true);
        cnt1 := kdtreequeryknn(tree1, qx, 1, true);
        if (cnt0=1) and (cnt1=1) then
        begin
            rxy0:=nil;
            rxy1:=nil;
            kdtreequeryresultsxy(tree0, rxy0);
            kdtreequeryresultsxy(tree1, rxy1);
            for J:=0 to nx+ny-1 do
                Result := Result and (rxy0[0,j]=rxy1[0,j]);
        end
        else
            Result := false;
    end;
    
    //
    // Test stream serialization/unserialization
    //
    // NOTE: we add a few symbols at the beginning and after the end of the data
    //       in order to test algorithm ability to work in the middle of the stream
    //
    MS:=TMemoryStream.Create();
    C:='b';
    MS.Write(C,1);
    C:=' ';
    MS.Write(C,1);
    C:='e';
    MS.Write(C,1);
    C:='g';
    MS.Write(C,1);
    kdtreeserialize(tree0, MS);
    C:='@';
    MS.Write(C,1);
    C:=' ';
    MS.Write(C,1);
    C:='n';
    MS.Write(C,1);
    C:='d';
    MS.Write(C,1);
    MS.Seek(0, soBeginning);
    MS.Read(C, 1);
    Result:=Result and (C='b');
    MS.Read(C, 1);
    Result:=Result and (C=' ');
    MS.Read(C, 1);
    Result:=Result and (C='e');
    MS.Read(C, 1);
    Result:=Result and (C='g');
    tree1:=nil;
    kdtreeunserialize(MS, tree1);
    MS.Read(C, 1);
    Result:=Result and (C='@');
    MS.Read(C, 1);
    Result:=Result and (C=' ');
    MS.Read(C, 1);
    Result:=Result and (C='n');
    MS.Read(C, 1);
    Result:=Result and (C='d');
    for i:=0 to 99 do
    begin
        for J:=0 to NX-1 do
            qx[j] := hqrndnormal(rs);
        cnt0 := kdtreequeryknn(tree0, qx, 1, true);
        cnt1 := kdtreequeryknn(tree1, qx, 1, true);
        if (cnt0=1) and (cnt1=1) then
        begin
            rxy0:=nil;
            rxy1:=nil;
            kdtreequeryresultsxy(tree0, rxy0);
            kdtreequeryresultsxy(tree1, rxy1);
            for j:=0 to NX+NY-1 do
                Result := Result and (rxy0[0,j]=rxy1[0,j]);
        end
        else
            Result:=False;
    end;
    
    //
    // Result
    //
    WriteLn('* serialization (kd-trees)   '+StrIfThen(Result, 'OK', 'FAILED'));
    if not Result then
        Exit;
        
        
end;


////////////////////////////////////
//
// Tests copying of ALGLIB objects
//
// On failure returns False.
// On success returns True.
// May throw exception on internal error (must be catched by caller).
////////////
function ObjectsCopyingTests():Boolean;
var
    rs0, rs1: Thqrndstate;
begin
    Result:=True;
    
    //
    // Test that cloning ALGLIB RNG object results in creation of independent copy
    // (if it is still same object, second call to hqrnduniformr() will return different value)
    //
    hqrndrandomize(rs0);
    rs1:=rs0.Clone();
    Result:=Result and (hqrnduniformr(rs0)=hqrnduniformr(rs1));
    
    //
    // Result
    //
    WriteLn('* cloning of objects         '+StrIfThen(Result, 'OK', 'FAILED'));
end;


////////////////////////////////////
//
// Tests performance of GEMM function
//
// Always succeeds
////////////
procedure GEMMPerformanceTest();
var
    rs: Thqrndstate;
    t0, t1: TDateTime;
    A, B, C: TMatrix;
    I, J, N, Cnt, MinRunTime: Integer;
    V: Double;
begin
    rs:=nil;
    N:=1024;
    MinRunTime:=10;
    try
        // prepare arrays
        hqrndrandomize(rs);
        SetLength(A, N, N);
        SetLength(B, N, N);
        SetLength(C, N, N);
        for I:=0 to N-1 do
            for J:=0 to N-1 do
            begin
                A[I,J]:=HQRNDNormal(RS);
                B[I,J]:=HQRNDNormal(RS);
                C[I,J]:=0.0;
            end;
            
        // try with sequential code
        Cnt:=0;
        t0:=Now();
        while SecondsBetween(Now(),t0)<MinRunTime do
        begin
            rmatrixgemm(N, N, N,
                1.0,
                A, 0, 0, 0,
                B, 0, 0, 0,
                0.0,
                C, 0, 0);
            Inc(Cnt);
        end;
        t1:=Now();
        V:=N;
        V:=2*Power(V,3);
        V:=V*Cnt;
        V:=V/SecondsBetween(t1,t0);
        V:=V/1000000;
        WriteLn('* GEMM-SEQ:    ', V:9:1, ' MFLOPS');
            
        // try with parallel code, nworkers=1
        Cnt:=0;
        t0:=Now();
        SetNWorkers(1);
        while SecondsBetween(Now(),t0)<MinRunTime do
        begin
            rmatrixgemm(N, N, N,
                1.0,
                A, 0, 0, 0,
                B, 0, 0, 0,
                0.0,
                C, 0, 0,
                AlglibParallel);
            Inc(Cnt);
        end;
        t1:=Now();
        V:=N;
        V:=2*Power(V,3);
        V:=V*Cnt;
        V:=V/SecondsBetween(t1,t0);
        V:=V/1000000;
        WriteLn('* GEMM-SMP1:   ', V:9:1, ' MFLOPS');
            
        // try with parallel code, nworkers=NCores
        Cnt:=0;
        t0:=Now();
        SetNWorkers(0);
        while SecondsBetween(Now(),t0)<MinRunTime do
        begin
            rmatrixgemm(N, N, N,
                1.0,
                A, 0, 0, 0,
                B, 0, 0, 0,
                0.0,
                C, 0, 0,
                AlglibParallel);
            Inc(Cnt);
        end;
        t1:=Now();
        V:=N;
        V:=2*Power(V,3);
        V:=V*Cnt;
        V:=V/SecondsBetween(t1,t0);
        V:=V/1000000;
        WriteLn('* GEMM-SMPN:   ', V:9:1, ' MFLOPS');
    finally
        FreeAndNil(rs);
    end;
end;


begin
    ExitCode:=0;
    Randomize();
    try
        //
        // Basic tests of X-interface
        //
        WriteLn('Basic tests:');
        if not BasicTests1D() then
        begin
            ExitCode:=1;
            Exit;
        end;
        if not BasicTests2D() then
        begin
            ExitCode:=1;
            Exit;
        end;
        if not BasicTestsOther() then
        begin
            ExitCode:=1;
            Exit;
        end;
        
        //
        // Advanced tests
        //
        WriteLn('Advanced tests:');
        if not KDTreeSerializationTests() then
        begin
            ExitCode:=1;
            Exit;
        end;
        if not ObjectsCopyingTests() then
        begin
            ExitCode:=1;
            Exit;
        end;
        
        //
        // Performance tests
        //
        WriteLn('Performance tests:');
        GEMMPerformanceTest();
    except
        on E: Exception do
        begin
            WriteLn('Unexpected exception, message is: '+E.Message);
            ExitCode:=1;
            Exit;
        end;
    end;
end.

USE [QLDSV_TC]
GO
/****** Object:  StoredProcedure [dbo].[GetAllHocKy]    Script Date: 10/4/2021 4:24:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[GetAllHocKy] @NIENKHOA nchar(9)  as 
select HOCKY from LOPTINCHI where NIENKHOA= @NIENKHOA group by HOCKY


GO
/****** Object:  StoredProcedure [dbo].[GetAllNhom]    Script Date: 10/4/2021 4:24:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[GetAllNhom] @NIENKHOA varchar(9), @HOCKI int
as select NHOM FROM LOPTINCHI where @NIENKHOA = NIENKHOA AND HOCKY = @HOCKI group by NHOM


GO
/****** Object:  StoredProcedure [dbo].[GetAllNienKhoa]    Script Date: 10/4/2021 4:24:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[GetAllNienKhoa] as 
select NIENKHOA from LOPTINCHI group by NIENKHOA


GO
/****** Object:  StoredProcedure [dbo].[SP_GetCTHP_SV]    Script Date: 10/4/2021 4:24:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[SP_GetCTHP_SV]
@MASV VARCHAR(10), @NIENKHOA NCHAR(9), @HOCKY INT
AS SELECT NGAYDONG, SOTIENDONG FROM dbo.CT_DONGHOCPHI WHERE NIENKHOA = @NIENKHOA AND HOCKY = @HOCKY AND MASV = @MASV



GO
/****** Object:  StoredProcedure [dbo].[SP_GetDSHP_SV]    Script Date: 10/4/2021 4:24:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[SP_GetDSHP_SV]
@MASV VARCHAR(10)
AS
BEGIN
	with GETINFOHP(MASV,NIENKHOA,HOCKY,TONGSOTIENDADONG)
as (select HOCPHI.MASV,HOCPHI.NIENKHOA,HOCPHI.HOCKY,SUM(SOTIENDONG) from HOCPHI,CT_DONGHOCPHI 
where HOCPHI.MASV = CT_DONGHOCPHI.MASV AND HOCPHI.NIENKHOA = CT_DONGHOCPHI.NIENKHOA AND HOCPHI.HOCKY = CT_DONGHOCPHI.HOCKY
group by HOCPHI.MASV,HOCPHI.NIENKHOA,HOCPHI.HOCKY)
select HOCPHI.NIENKHOA,HOCPHI.HOCKY,HOCPHI,TONGSOTIENDADONG=COALESCE(TONGSOTIENDADONG,0), SOTIENCANDONG= COALESCE(HOCPHI-TONGSOTIENDADONG,HOCPHI) 
from HOCPHI left join GETINFOHP
on HOCPHI.MASV = GETINFOHP.MASV AND HOCPHI.NIENKHOA = GETINFOHP.NIENKHOA AND HOCPHI.HOCKY = GETINFOHP.HOCKY
where HOCPHI.MASV = @MASV
END

GO
/****** Object:  StoredProcedure [dbo].[SP_GetInfoSV_HP]    Script Date: 10/4/2021 4:24:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[SP_GetInfoSV_HP]
@masv VARCHAR(10)
AS SELECT HOTEN=HO + TEN, MALOP FROM dbo.SINHVIEN WHERE MASV = @masv
GO
/****** Object:  StoredProcedure [dbo].[SP_InDanhSachDongHP]    Script Date: 10/4/2021 4:24:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_InDanhSachDongHP] @MALOP varchar(10), @NienKhoa varchar(9), @HocKy int
as
with GETSVDONGTIEN(MASV,HOCPHI,SOTIENDONG)
as
(select HOCPHI.MASV,HOCPHI,SOTIENDADONG = SUM(SOTIENDONG) 
from HOCPHI left join CT_DONGHOCPHI
on HOCPHI.MASV = CT_DONGHOCPHI.MASV AND CT_DONGHOCPHI.HOCKY = HOCPHI.HOCKY AND CT_DONGHOCPHI.NIENKHOA = HOCPHI.NIENKHOA
where HOCPHI.NIENKHOA = @NienKhoa AND HOCPHI.HOCKY = @HocKy
group by HOCPHI.MASV,HOCPHI)
select HOTEN=SINHVIEN.HO + ' '+ SINHVIEN.TEN,HOCPHI,SOTIENDONG= COALESCE(SOTIENDONG,0)  
from SINHVIEN,GETSVDONGTIEN
where SINHVIEN.MASV = GETSVDONGTIEN.MASV
AND SINHVIEN.MALOP = @MALOP
GO
/****** Object:  StoredProcedure [dbo].[SP_Lay_Thong_Tin_GV_Tu_Login]    Script Date: 10/4/2021 4:24:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[SP_Lay_Thong_Tin_GV_Tu_Login]
 @TENLOGIN NVARCHAR(100)
 AS
 DECLARE @UID INT
 DECLARE @MAGV NVARCHAR(100)
 SELECT @UID = uid, @MAGV = name FROM SYS.sysusers
	WHERE sid = SUSER_SID(@TENLOGIN)
 SELECT MAGV = @MAGV,
		HOTEN = (SELECT HO+ ' '+TEN FROM dbo.GIANGVIEN WHERE MAGV=@MAGV),
		TENNHOM= name
		FROM SYS.sysusers
		WHERE uid = (SELECT groupuid FROM SYS.sysmembers WHERE memberuid = @UID)
GO
/****** Object:  StoredProcedure [dbo].[SP_LayDSGV]    Script Date: 10/4/2021 4:24:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create PROCEDURE [dbo].[SP_LayDSGV] AS
BEGIN
	SELECT MAGV,HOTEN = HO+' '+TEN FROM dbo.GIANGVIEN 
END
GO
/****** Object:  StoredProcedure [dbo].[SP_LayThongTinSV_DangNhap]    Script Date: 10/4/2021 4:24:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[SP_LayThongTinSV_DangNhap]
@masv NCHAR(10),@password NVARCHAR(40)
AS
BEGIN
	SELECT MASV,HOTEN = HO+' '+TEN FROM dbo.SINHVIEN WHERE MASV = @masv 
END
GO
/****** Object:  StoredProcedure [dbo].[SP_TAOLOGIN]    Script Date: 10/4/2021 4:24:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[SP_TAOLOGIN]
  @LGNAME VARCHAR(50),
  @PASS VARCHAR(50),
  @USERNAME VARCHAR(50),
  @ROLE VARCHAR(50)
AS

	-- check login , user bị trùng 
	IF EXISTS(SELECT name FROM sys.server_principals 
				WHERE TYPE IN ('U', 'S', 'G')	--U: Windows Login Accounts
				AND name NOT LIKE '%##%'		--S: SQL Login Accounts
				AND name = @LGNAME)				--G: Windows Group Login Accounts
		RETURN 1	--Trùng Login
	ELSE IF EXISTS(SELECT name FROM sys.database_principals
					WHERE type_desc = 'SQL_USER'
					AND name = @USERNAME)
		RETURN 2	--Trùng User

	-- băt đầu tạo tài khoản
  DECLARE @RET INT
  EXEC @RET= SP_ADDLOGIN @LGNAME, @PASS,'QLDSV'
  IF (@RET =1) 
     RETURN 3 -- tạo tài khoản không thành công
 
  EXEC @RET= SP_GRANTDBACCESS @LGNAME, @USERNAME
  IF (@RET =1) 
  BEGIN
       EXEC SP_DROPLOGIN @LGNAME
       RETURN 3 -- tạo  tài khoảng không thành công
  END
  EXEC sp_addrolemember @ROLE, @USERNAME

  --THEM ROLE SECURITYADMIN DE CO QUYEN TAO TAI KHOAN
  EXEC sp_addsrvrolemember @LGNAME, 'SecurityAdmin'

  RETURN 0  -- THANH CONG
GO
/****** Object:  StoredProcedure [dbo].[SP_TongTienHocPhi]    Script Date: 10/4/2021 4:24:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_TongTienHocPhi] @MALOP varchar(10), @NienKhoa varchar(9), @HocKy int
AS

DECLARE @tonghocphi INT
;with GETSVDONGTIEN(MASV,HOCPHI,SOTIENDONG)
as
(select HOCPHI.MASV,HOCPHI,SOTIENDADONG = SUM(SOTIENDONG) 
from HOCPHI left join CT_DONGHOCPHI
on HOCPHI.MASV = CT_DONGHOCPHI.MASV AND CT_DONGHOCPHI.HOCKY = HOCPHI.HOCKY AND CT_DONGHOCPHI.NIENKHOA = HOCPHI.NIENKHOA
where HOCPHI.NIENKHOA = @NienKhoa AND HOCPHI.HOCKY = @HocKy
group by HOCPHI.MASV,HOCPHI)
select @tonghocphi =SUM(A.SOTIENDONG) from (select HOTEN=SINHVIEN.HO + ' '+ SINHVIEN.TEN,HOCPHI,SOTIENDONG= COALESCE(SOTIENDONG,0)  
from SINHVIEN,GETSVDONGTIEN
where SINHVIEN.MASV = GETSVDONGTIEN.MASV
AND SINHVIEN.MALOP = @MALOP) as A
PRINT(@tonghocphi)
IF(@tonghocphi IS NULL) 
SELECT TONGHOCPHI = 0
ELSE SELECT TONGHOCPHI = @tonghocphi
GO
/****** Object:  StoredProcedure [dbo].[SV_DONGTIEN]    Script Date: 10/4/2021 4:24:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[SV_DONGTIEN] @MASV varchar(20),@NienKhoa varchar (20), @HocKy int, @SoTienDong int
as

if exists (select 1 from HOCPHI where MASV = @MASV AND NIENKHOA = @NienKhoa AND HOCKY = @HocKy)
	begin
		insert into CT_DONGHOCPHI(MASV,NIENKHOA,HOCKY,SOTIENDONG)
		values (@MASV,@NienKhoa,@HocKy,@SoTienDong)
	end
else
	raiserror(N'Thông tin bạn nhập không tồn tại',16,1)
	 

GO
/****** Object:  StoredProcedure [dbo].[TAO_THONGTINHOCPHI]    Script Date: 10/4/2021 4:24:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[TAO_THONGTINHOCPHI] @MASV varchar(20),@NienKhoa varchar (20), @HocKy int, @HocPhi int
as
if exists (select 1 from HOCPHI where MASV = @MASV AND NIENKHOA = @NienKhoa AND HOCKY = @HocKy)
	begin
		raiserror(N'ĐÃ TỒN TẠI THÔNG TIN HỌC PHÍ',16,1)
	end
else
	begin
		insert into HOCPHI(MASV,NIENKHOA,HOCKY,HOCPHI)
		values (@MASV,@NienKhoa,@HocKy,@HocPhi)
		
	end
	 

GO

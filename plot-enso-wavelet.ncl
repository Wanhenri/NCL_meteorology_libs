load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

begin

  f      = addfile("./data/ENSO-index.nc", "r") 
  ensoi  = f->ensoi
  
  time = ensoi&year
  
  N  = dimsizes(ensoi)
  
  ;; С������
  mother  = 0       ; ĸС�����ͣ�ͨ��Ϊ0����'Morlet'С�����������б��ֱ�Ϊ1��'Paul'С����2��'DOG' (derivative of Gaussian)С��
  dt      = 1       ; ��������ֵ֮���ʱ������ͨ��Ϊ1�������б�ʾ���1�ꡣ
  param   = -1      ; ĸС�������� ���param < 0����ʹ��Ĭ����ֵ��������'Morlet'С��ʱΪ6��Paul'С��Ϊ4;'DOG'С��Ϊ2
  s0      = dt      ; 'Morlet'С��s0 = dt ; 'Paul'С��s0 = dt/4  
  dj      = 0.25    ; �����趨
  jtot    = 1+floattointeger(((log10(N*dt/s0))/dj)/log10(2.)) ; �����趨
  npad    = N       ; �����趨
  nadof   = 0       ; �����趨
  noise   = 1       ; �����趨,h����������
  siglvl  = .05     ; ���Ŷ�ˮƽ
  isigtest= 0       ; ����chi-square ���飻��Ϊ1���Ƕ�ȫ�����׽���ʱ��ƽ������


  ;************************************
  power            = onedtond(w@power,(/jtot,N/))  ; ������
  power!0          = "period"                      ; Y axis
  power&period     = w@period                     

  power!1          = "time"                        ; X axis
  power&time       = time

  power@long_name  = "Power Spectrum"
  power@units      = "1/unit-freq"

  ;���������� ( >= 1 ������)
  SIG              = power                         ; ����Ԫ����
  SIG              = power/conform (power,w@signif,0)
  SIG@long_name    = "Significance"
  SIG@units        = " "

 ;*************************************************
  wks = gsn_open_wks("eps","plot-enso-wavelet")             
  gsn_define_colormap(wks,"BlAqGrYeOrReVi200")   
 
  YLValues = (/1,2,4,8,16/)
  YLLabels = (/"1","2","4","8","16"/)
  
  res                     = True                  
  res@gsnDraw             = False              
  res@gsnFrame            = False                 
  res@gsnRightString      = " "
  res@gsnLeftString       = " "

  res@trYReverse = True                  ; ���� y-axis
  res@tmYLMode   = "Explicit"
  res@tmYLValues = YLValues
  res@tmYLLabels = YLLabels
  res@tmLabelAutoStride   = True

  res@trYMaxF        = max(YLValues)
  ;res@trYMinF        = min(YLValues)

  res@cnLinesOn      = False               
  res@cnLineLabelsOn = False
  res@cnInfoLabelOn  = False
    
  res2 = res
 
  res@tiYAxisString       = "Years"  

  res@cnFillOn            = True                 
  res@cnFillMode          = "RasterFill"          
  res@cnRasterSmoothingOn = True                  
  
  ;;;;;;;;;;;;;
  res2@cnLevelSelectionMode = "ManualLevels" 
  res2@cnMinLevelValF       = 0.00        
  res2@cnMaxLevelValF       = 2.00        
          
  res2@cnFillScaleF         = 0.5     ; ������״�����ܶȣ�ͨ���������ShadeGtContourʵ����״��䣩

  plot = gsn_csm_contour(wks,power,res)
  iplot = gsn_csm_contour(wks,SIG,res2)

   ; ��״���
  overlay(plot,iplot)				; ��ԭͼ������������

   ;���б߽�ЧӦ�������������ʾ
  
  ;;���Ӹ�Ƶ�ʵĹ��� 
  gws = w@gws
  resl = True
  resl@gsnFrame      = False
  resl@gsnDraw       = False
  resl@trYAxisType   = "LogAxis"
  resl@trYReverse    = True                  ; reverse y-axis
  resl@tmYLMode      = "Explicit"
  resl@tmYLValues    = YLValues
  resl@tmYLLabels    = YLLabels
  resl@trYMaxF       = max(YLValues)
  resl@trYMinF       = min(YLValues) 
  resl@tiXAxisString = "Global Wavelet Power"

  plotg = gsn_csm_xy(wks,gws,power&period,resl) 
  
  ;; ��plotg������plot���Ҳ�
   

 draw(plot)
 frame(wks)
end

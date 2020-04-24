package online.miantiao.utils;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import org.apache.poi.hssf.usermodel.HSSFWorkbook;
import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.Workbook;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.multipart.commons.CommonsMultipartFile;

import online.miantiao.Entity.TAZAccessibilityInfo;

public class ReadTAZAccessibilityExcel {

	// 总行数
	private int totalRows = 0;
	// 总列数
	private int totalCells = 0;
	// 错误信息接收器
	private String errorMsg;

	// 构造方法
	public ReadTAZAccessibilityExcel() {
	}

	// 获取总行数
	public int getTotalRows() {
		return totalRows;
	}

	// 获取总列数
	public int getTotalCells() {
		return totalCells;
	}

	// 获取错误信息-暂时未用到暂时留着
	public String getErrorInfo() {
		return errorMsg;
	}

	/**
	 * 读EXCEL文件
	 * 
	 * @param fielName
	 * @return
	 */
	public List<TAZAccessibilityInfo> getExcelInfo(MultipartFile Mfile) {

		// 把spring文件上传的MultipartFile转换成CommonsMultipartFile类型
		CommonsMultipartFile cf = (CommonsMultipartFile) Mfile;
		// 获取本地存储路径
		File file = new File("D:\\fileupload");
		// 创建一个目录 （它的路径名由当前 File 对象指定，包括任一必须的父路径。）
		if (!file.exists())
			file.mkdirs();
		// 新建一个文件
		File file1 = new File("D:\\fileupload\\" + new Date().getTime() + ".xls");
		// 将上传的文件写入新建的文件中
		try {
			cf.getFileItem().write(file1);
		} catch (Exception e) {
			e.printStackTrace();
		}

		// 初始化可达性信息的集合
		List<TAZAccessibilityInfo> tazAccessibilityInfoList = new ArrayList<TAZAccessibilityInfo>();
		// 初始化输入流
		FileInputStream is = null;
		Workbook wb = null;
		try {
			// 根据新建的文件实例化输入流
			is = new FileInputStream(file1);
			// 根据excel里面的内容读取客户信息
			// 当excel是2003时
			if (CheckFileType.isExcel2003(Mfile.getOriginalFilename()))
				wb = new HSSFWorkbook(is);
			// 当excel是2007时
			if (CheckFileType.isExcel2007(Mfile.getOriginalFilename()))
				wb = new XSSFWorkbook(is);
			// 读取Excel里的信息
			if (wb != null)
				tazAccessibilityInfoList = readExcelValue(wb);
			is.close();
		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			if (is != null) {
				try {
					is.close();
				} catch (IOException e) {
					is = null;
					e.printStackTrace();
				}
			}
		}
		return tazAccessibilityInfoList;
	}

	/**
	 * 读取Excel里面的详细信息
	 * 
	 * @param wb
	 * @return
	 */
	private List<TAZAccessibilityInfo> readExcelValue(Workbook wb) {
		// 得到第一个sheet
		Sheet sheet = wb.getSheetAt(0);

		// 得到Excel的行数
		this.totalRows = sheet.getPhysicalNumberOfRows();

		// 得到Excel的列数(前提是有行数)
		// 判断行数大于一，并且第一行必须有标题（这里有bug，若文件第一行没标题值就完了）
		if (totalRows >= 1 && sheet.getRow(0) != null) {
			this.totalCells = sheet.getRow(0).getPhysicalNumberOfCells();
		} else {
			return null;
		}

		List<TAZAccessibilityInfo> tazAccessibilityInfoList = new ArrayList<TAZAccessibilityInfo>();
		TAZAccessibilityInfo tazAccessibilityData;
		// 声明一个对象
		// NumberFormat nf = NumberFormat.getInstance();
		// 这种方法对于自动加".0"的数字可直接解决
		// 但如果是科学计数法的数字就转换成了带逗号的，例如：12345678912345的科学计数法是1.23457E+13，经过这个格式化后就变成了字符串“12,345,678,912,345”，这也并不是想要的结果，所以要将逗号去掉
		// if (s.indexOf(",") >= 0) {
		// s = s.replace(",", "");
		// }
		// 循环Excel行数,从第二行开始。标题不入库
		for (int r = 1; r < totalRows; r++) {
			Row row = sheet.getRow(r);
			if (row == null)
				continue;
			tazAccessibilityData = new TAZAccessibilityInfo();
			// 循环Excel的列
			for (int c = 0; c < this.totalCells; c++) {
				Cell cell = row.getCell(c);
				if (null != cell) {
					if (c == 0) {
						tazAccessibilityData.setFid((int) cell.getNumericCellValue());// 得到行中第一个值
					} else if (c == 1) {
						tazAccessibilityData.setAccessibility((int) cell.getNumericCellValue());// 得到行中第二个值
					}
				}
			}
			// 添加对象到集合中
			tazAccessibilityInfoList.add(tazAccessibilityData);
		}
		return tazAccessibilityInfoList;
	}

}

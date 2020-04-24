package online.miantiao.Entity;

/**
 * 可达性基础类，包含交通分析区的FID和与之对应的公交线路可达性Accessibility
 * 
 * @author 面条
 *
 */
public class TAZAccessibilityInfo {
	
	//交通分析区的主键ID
	private int fid;
	
	//交通分析区的可达性
	private int accessibility;

	public int getFid() {
		return fid;
	}

	public void setFid(int fid) {
		this.fid = fid;
	}

	public double getAccessibility() {
		return accessibility;
	}

	public void setAccessibility(int accessibility) {
		this.accessibility = accessibility;
	}

	@Override
	public String toString() {
		return "TAZInfo [fid=" + fid + ", accessibility=" + accessibility + "]";
	}

}

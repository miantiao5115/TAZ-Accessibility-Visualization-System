package online.miantiao.Entity;

import java.util.HashMap;
import java.util.Map;

import org.springframework.stereotype.Component;

/**
 * 通用的返回的类
 * 
 */
@Component
public class ResultMessage {
	
	//状态码   100-成功    200-失败
	private int code;
	//提示信息
	private String msg;
	
	//用户要返回给浏览器的数据
	private Map<String, Object> resultMap = new HashMap<String, Object>();

	public ResultMessage success(){
		ResultMessage result = new ResultMessage();
		result.setCode(100);
		result.setMsg("处理成功！");
		return result;
	}
	
	public ResultMessage fail(){
		ResultMessage result = new ResultMessage();
		result.setCode(200);
		result.setMsg("处理失败！");
		return result;
	}
	
	public ResultMessage add(String key,Object value){
		this.getResultMap().put(key, value);
		return this;
	}

	public int getCode() {
		return code;
	}

	public void setCode(int code) {
		this.code = code;
	}

	public String getMsg() {
		return msg;
	}

	public void setMsg(String msg) {
		this.msg = msg;
	}

	public Map<String, Object> getResultMap() {
		return resultMap;
	}

	public void setResultMap(Map<String, Object> resultMap) {
		this.resultMap = resultMap;
	}

	@Override
	public String toString() {
		return "ResultMessage [code=" + code + ", msg=" + msg + ", resultMap=" + resultMap + "]";
	}
	
}

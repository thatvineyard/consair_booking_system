package ospp.bookinggui.networking.messages;

import ospp.bookinggui.networking.Message;

import java.io.UnsupportedEncodingException;

public class GetFlightListRespMsg extends Message {
	@Override
	public byte[] constructBody() throws UnsupportedEncodingException {
		return new byte[0];
	}
}

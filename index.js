const express = require("express");
const { createServer } = require("http");
const { Server } = require("socket.io");
const cors = require("cors");
const app = express();
const fs = require("fs");
const ss = require("socket.io-stream");
app.use(cors());

const httpServer = createServer(app);
// httpServer.use(cors());

const io = new Server(httpServer, {
	maxHttpBufferSize: 1e7,
	cors: { origin: "*" },
});

function getAllRoomMembers(room, _nsp) {
	var roomMembers = [];
	var nsp = typeof _nsp !== "string" ? "/" : _nsp;

	for (var member in io._nsps.get("/").adapter.rooms[room]) {
		roomMembers.push(member);
	}

	return roomMembers;
}

io.on("connection", (socket) => {
	console.log(socket.id);
	socket.timeout(100000);

	socket.emit("your_id", { id: socket.id });

	socket.on("test", (data) => {
		console.log(data);
	});

	socket.on("join_figma_room", (data) => {
		console.log(data.my_id + " joined " + data.room);
		// console.log(getAllRoomMembers(data.room, "/"));
		// console.log(Object.keys(io.of("/" + data.room).sockets));
		socket.join(data.room);
		let users = "";
		io._nsps
			.get("/")
			.adapter.rooms.get(data.room)
			.forEach((e) => {
				if (e !== data.room) {
					console.log(e);
					users += "\n" + e;
				}
			});

		socket.broadcast.to(data.room).emit("user_joined", users);
	});

	socket.on("join_room", (room) => {
		console.log("Figma Plugin joining " + room);
		socket.join(room);
	});

	socket.on("error", (e) => {
		console.log("error");
		console.log(e);
	});

	socket.on("all_image", async (data) => {
		console.log("socket on image");
		console.log(data);
		socket.broadcast.to(data.room).emit("send_all_image_to_figma", {
			images: data.files,
		});
		// const buffer = Buffer.from(data.raw).toString("base64");
		// console.log(buffer.slice(0, 120));
		// socket.broadcast.emit("trying", {
		// 	name: data.name,
		// 	type: data.type,
		// 	buffer: buffer,
		// });

		// socket.emit("hello", {
		// 	name: data.name,
		// 	type: data.type,
		// 	raw: buffer,
		// });
	});
	socket.on("image", async (data) => {
		console.log("socket on image");
		console.log(data);
		socket.broadcast.to(data.room).emit("trying", {
			images: data.files,
		});
		// const buffer = Buffer.from(data.raw).toString("base64");
		// console.log(buffer.slice(0, 120));
		// socket.broadcast.emit("trying", {
		// 	name: data.name,
		// 	type: data.type,
		// 	buffer: buffer,
		// });

		// socket.emit("hello", {
		// 	name: data.name,
		// 	type: data.type,
		// 	raw: buffer,
		// });
	});
	socket.on("disconnect", (socket) =>
		console.log(`${socket} has disconnected`)
	);
	socket.on("reconnect", (socket) => console.log(`${socket} has reconnected`));
});

io.on("reconnect", (socket) => {
	console.log("reconnect");
	console.log(socket);
});

io.on("disconnect", (socket) => console.log(`${socket} has disconnected`));

httpServer.listen(3001, () => {
	console.log("Server running on 3001");
});
